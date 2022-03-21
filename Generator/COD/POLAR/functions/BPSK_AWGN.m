function yy = BPSK_AWGN(x)
%
% PCparams is implicit parameter
% 
% x  : a binary vector of arbitrary size.
% xx : Mapping
%             0 -> -sqrt(PCparams.Ec)
%             1 ->  sqrt(PCparams.Ec)
% y = xx + n, n ~ NN(0,N0/2)

global PCparams;

xx = (2*x-1)*sqrt(PCparams.Ec);
yy = xx + randn(size(xx)) * sqrt(PCparams.N0/2);

end