function u=pdecode(y)
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

%%%%%%%%DEBUGGING DECODER Part 1of2%%%%%%%%%
% TECHNIQUE: Compare the output with a sample output from other perfect decoder implementation
% y = [-2.29054 -2.42021 0.78617 -1.48262 -1.78447 -1.34204 1.82231 2.01136 -0.50112 -1.70260 -2.20256 -1.23027 -1.83809 -0.65077 0.92667 1.07634]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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

u = d_hat ( PCparams.FZlookup == -1);

% %%%%%%%%DEBUGGING DECODER Part 2of2%%%%%%%%%
% % TECHNIQUE: Compare the output with a sample output from other perfect decoder implementation
% % DEBUGGING
% fprintf('\n\n N=%d, K=%d, initdB=%.2f',N,PCparams.K,PCparams.designSNRdB);
% fprintf('\n FrozenBitsLookups Actual and Expected respectively =\n [');
% fprintf('%d ',PCparams.FZlookup); fprintf('\b]');
% fprintf('\n [0 0 0 -1 0 -1 0 -1 0 -1 0 -1 0 -1 -1 -1]\n\n');
% 
% fprintf('\n Received Vectors Actual & Expected respectively =\n [');
% fprintf('%.5f ',y'); fprintf('\b]');
% fprintf('\n [-2.29054 -2.42021 0.78617 -1.48262 -1.78447 -1.34204 1.82231 2.01136 -0.50112 -1.70260 -2.20256 -1.23027 -1.83809 -0.65077 0.92667 1.07634]\n\n');
% 
% fprintf('\n Initial Likelihoods Vectors Actual & Expected respectively =\n [');
% fprintf('%.5f ',initialLRs'); fprintf('\b]');
% fprintf('\n [4.58109 4.84043 -1.57235 2.96523 3.56893 2.68408 -3.64461 -4.02271 1.00224 3.40520 4.40512 2.46054 3.67618 1.30155 -1.85335 -2.15268]\n\n');
% 
% fprintf('\n FINAL o/p Likelihoods Vectors Actual & Expected respectively =\n [');
% fprintf('%.5f ',finalLRs'); fprintf('\b]');
% fprintf('\n [-0.09647 1.25093 1.65714 8.74567 0.39491 6.98428 5.69810 20.24560 -0.69722 -4.64566 4.73276 -19.65780 2.06594 -15.43850 13.90370 -44.99160]\n\n');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end