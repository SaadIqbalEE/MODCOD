function xx = BPSK(x)
%
% PCparams is implicit parameter
% 
% x  : a binary vector of arbitrary size.
% xx : Mapping
%             0 -> -sqrt(PCparams.Ec)
%             1 ->  sqrt(PCparams.Ec)

global PCparams;

xx = (2*x-1)*sqrt(PCparams.Ec);

end