function [y,x]=EncoderA(y,x)
% EncoderA of the paper:
%   "Efficient Algorithms for Systematic Polar Encoding",
%    Harish Vangala, Yi Hong, and Emanuele Viterbo.
%

global PCparams;
n=PCparams.n;
N=PCparams.N;

X = zeros(PCparams.N,1+PCparams.n); %initialize
X(:,1) = y;
X(:,n+1) = x;

for i=N:-1:1
    if(PCparams.FZlookup(i)==-1)
        s=n+1;
        delta=-1;
    else
        s=1;
        delta=1;
    end

    str=dec2bin(i-1,n);
    
    for j=1:n
        t = s+j*delta;
        l=min([t,t-delta]);
        kappa=2^(n-l);
        if(str(l)=='1')
            X(i,t) = X(i,t-delta);
        else
            X(i,t) = mod(X(i,t-delta)+X(i+kappa,t-delta), 2);
        end
    end
end
y=X(:,1);
x=X(:,n+1);
% X
end