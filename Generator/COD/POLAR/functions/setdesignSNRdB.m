function setdesignSNRdB(designsnrdb)
%
% sets PCparams & reconstructs accordingly
%
% DONT PLEASE SIMPLY REPLACE VALUE OF "PCparams.designSNRdB" 
%                                           It means nothing

global PCparams;

PCparams.designSNRdB = designsnrdb;

% Set the frozens by reconstruction
PCparams.FZlookup = pcc(N,K,designsnrdb); % Construct at 0dB
end