function [x,y]=systematic_pencode(u,algoname)
% Encode 'K' message bits in 'u' and
% Return 'N' encoded bits in 'x'
%
% The order of outputs is chosen so that when assigned to ONE
% variable directly, we get the (default) output as the desired codeword x.
%
% 'algoname' is a character that must be 'A' or 'B' or 'C', as in the paper:
%   "Efficient Algorithms for Systematic Polar Encoding", IEEE Communication Letters,
%    Harish Vangala, Yi Hong, and Emanuele Viterbo.
% its default value is 'A'. (Hence is optional to be supplied explicitly)
% Each of these letters corresponds to a specific algorithm
%
% PCparams structure is implicit parameter
%
% Polar coding parameters (N,K,FZlookup,Ec,N0,LLR,BITS) are taken
% from "PCparams" structure FZlookup is a vector, to lookup each integer
% index 1:N and check if it is a message-bit location or frozen-bit location.
%     FZlookup(i)==0 or 1 ==> bit-i is a frozenbit
%     FZlookup(i)==-1 ==> bit-i is a messagebit

if(nargin==1)
    algoname='A';
end

global PCparams;
N=PCparams.N;
n=PCparams.n;

y = PCparams.FZlookup; %loads all frozenbits, incl. -1
x = PCparams.FZlookup;

x(PCparams.FZlookup == -1) = u; 
x(PCparams.FZlookup ~= -1) = -1;

if(algoname=='A')
    [y,x]=EncoderA(y,x);
elseif(algoname=='B')
    r=zeros(N,1);
    [~,y,x] = EncoderB(1,N,y,x,r);
elseif(algoname=='C')
    r=zeros(N,1);
    [y,x,~] = EncoderC(1,N,y,x,r);
else
    fprintf('\n Invalid Encoder Algorithm %c Supplied! (should be one of A B C)\n',algoname);
end

end