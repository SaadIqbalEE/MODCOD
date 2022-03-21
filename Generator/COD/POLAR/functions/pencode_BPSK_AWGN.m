function yy = pencode_BPSK_AWGN(u)
%
% PCparams is implicit parameter
% 
% u  : a binary vector of size K
% x  : a binary vector of size N.
% xx : Mapping
%             0 -> -sqrt(PCparams.Ec)
%             1 ->  sqrt(PCparams.Ec)
% yy = xx + n, n ~ NN(0,N0/2)

global PCparams;

x = pencode(u);
xx = (2*x-1)*sqrt(PCparams.Ec);
yy = xx + randn(size(xx)) * sqrt(PCparams.N0/2);

end