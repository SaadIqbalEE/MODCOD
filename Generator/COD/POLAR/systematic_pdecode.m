function u=systematic_pdecode(y)
% PCparams structure is implicit parameter
%
% y    : Received bits in an AWGN (of noise variance N0/2, available via "PCparams")
% u    : Decoded message bits
%
% Polar coding parameters (N,K,FZlookup,Ec,N0,LLR,BITS) are taken
% from "PCparams" structure FZlookup is a vector, to lookup each integer
% index 1:N and check if it is a message-bit location or frozen-bit location.
%
%        FZlookup(i)==0 or 1 ==> bit-i is a frozenbit
%        FZlookup(i)==  -1   ==> bit-i is a messagebit
%
% PCparams.Ec   : The encoded bits power before entering AWGN
% PCparams.N0   : 2 times the Noise variance
% PCparams.LLR  : Log-Likelihood Ratios data structure for SC decoding
%                    vector of 1 x 2N-1
% PCparams.BITS : Intermediate bit decisions for SC decoding
%                    matrix of 2 x N-1
% -----
% NOTE:
%       EbN0 : If "SNR" is the signal-to-noise ratio of the AWGN;
%                 Eb/N0 = (Ec/N0) * (N/K) = (SNR/2) * (N/K)

global PCparams;
N=PCparams.N;

% Initializing the likelihoods (i.e. the right end of the butterfly str)
PCparams.LLR = 0; %PCparams.BITS=-1;
initialLRs = -(4*sqrt(PCparams.Ec)/PCparams.N0) * y; 
PCparams.LLR(N:2*N-1) = initialLRs;
% Explanation:
% ------------
%   y(i) = x(i) + n; x \in {+sqrt(Ec),-sqrt(Ec)}; n ~ Gaussian(0,N0/2)
%   LLR(i) = Pr{y(i) | x(i) = -sqrt(Ec)} / Pr{y(i) | x(i) = +sqrt(Ec)}
%   Pr(y|x) = (1/sqrt(2*pi* (N0/2))) * exp( (y-x)^2 / (2*(N0/2)) )

d_hat = zeros(N,1);
finalLRs = zeros(N,1); %DEBUG
for j=1:N

        i = bitreversed(j-1,PCparams.n) +1 ; % "+1" is for base-1 indexing
        updateLLR(i);
        finalLRs(i) = PCparams.LLR(1); %DEBUG
    if PCparams.FZlookup(i) == -1
        if PCparams.LLR(1) > 0
            d_hat(i) = 0;
        else
            d_hat(i) = 1;
        end
    else
        d_hat(i) = PCparams.FZlookup(i);
    end
    
        updateBITS(d_hat(i),i);
end

%%%%%%%% This is the only difference compared to, the original "pdecode()"

% The message bits are available after ONE non-systematic-encoding
% operation of the decoded d_hat; available precisely at
% non-frozen locations.
% x_hat = pencode(d_hat(PCparams.FZlookup == -1));
x_hat = FN_transform(d_hat);
u = x_hat ( PCparams.FZlookup==-1 );

end