function plotPC(N,K,EbN0dBrange,designSNRdB,verbose_output_flag) %designSNRdB is optional
% Plot the performance curve for (N,K) polar code
% Uses all-zero codeword transmission
% 
%    Usage: plotPC(N,K,EbN0dBrange,designSNRdB)
%
%       N - Block length
%       K - Message length
%       EbN0dBrange (=0:1:2, default) - the range of Eb/N0 values (in dB)
%                                           to simulate FER/BER
%       designSNRdB(=0dB, default) - The design-SNR=Ec/N0 at which the
%                                      polar code is to be constructed
%
%       verbose_output_flag - whether to print status messsages
% 
%   Note: This routine, preserves the global structure PCparams. It changes
%   the structure but restores at the end. So subsequent calls to functions
%   pencode(),pdecode() etc all are not affected.

global PCparams;

if nargin==2 %if last 2 args are not supplied
    EbN0dBrange = 0:1:2; %default SNR range to quickly see the o/p
    designSNRdB = 0; 
    verbose_output_flag=0;
elseif nargin==3
    designSNRdB=0;
    verbose_output_flag=0;
elseif nargin==4
    verbose_output_flag=0;
elseif (nargin>5 || nargin<2)
    fprintf('\n   Usage: plotPC(N,K,EbN0dBrange,designSNRdB,verbose_output_flag)\n');
    fprintf('\n       N  -  Blocklength');
    fprintf('\n       K  -  Message length (Rate = K/N)');
    fprintf('\n       EbN0dBrange -  the range of Eb/N0 values in dB');
    fprintf('\n                           to Monte-Carlo simulate)');
    fprintf('\n       designSNRdB (optional) - the SNR at which the polar code should be constructed');
    fprintf('\n                                 (Here, SNR=Ec/N0 - by definition for a PCC, defaults to "0dB")');
    fprintf('\n       verbose_output_flag - whether to print detailed status of the simulation periodically\n\n');
    return;
end

PCparams1 = PCparams; %store the current

initPC(N,K,1,2, designSNRdB,1); %silent, no output

EbN0dB = EbN0dBrange;

MCsize = 10000; %Montecarlo size

global BER;
global FER;

BER = zeros(1,length(EbN0dB));
FER = zeros(1,length(EbN0dB));

if(~verbose_output_flag)
    fprintf('Completed SNR points (out of %d): ',length(EbN0dB));
end

for j=1:length(EbN0dB)
tt=tic();
    N0 = PCparams.N0;
    Ec = (K/N)*N0*10^(EbN0dB(j)/10);
    
    PCparams.Ec = Ec; %normalized Ec %necessary for pencode(), pdecode()

    for l=1:MCsize
        tic
        u=randi(2,K,1)-1; %Bernoulli(0.5)
        x=pencode(u);
        txvec = (2*x-1)*sqrt(Ec);
        y = txvec + sqrt(N0/2)*randn(N,1);
        uhat = pdecode(y);
        
        nfails = sum(uhat ~= u);
        FER(j) = FER(j) + (nfails>0);
        BER(j) = BER(j) + nfails;
        
        if(verbose_output_flag)
        if mod(l,200)==0
        fprintf('Eb/N0 = %.1f dB and iteration-%d: %.2f sec : %d FEs, %d BEs %c',EbN0dB(j),l,toc,FER(j),BER(j),char(10)); %DEBUG NOTE
        end
        end
        
        if l>=1000 && FER(j)>=200  %frame errors, sufficient to stop
            break;
        end
    end
    FER(j) = FER(j)/l;
    BER(j) = BER(j)/(K*l);
if(verbose_output_flag)
    toc(tt);
else
    fprintf('\n %.2f dB (time taken:%.2f sec)',EbN0dB(j),toc(tt));
end
end

 subplot(211);
 semilogy(EbN0dB,FER); grid on;
 titlestr = sprintf('N=%d R=%.2f Polar code performance (designSNR=%.1dB)',N,(K/N),designSNRdB);
 title(titlestr);
 xlabel('Eb/N0 in dB');
 ylabel('Frame Error Rate');
 
 subplot(212);
 semilogy(EbN0dB,BER); grid on;
 titlestr = sprintf('N=%d R=%.2f Polar code performance (designSNR=%.1dB)',N,(K/N),designSNRdB);
 title(titlestr);
 xlabel('Eb/N0 in dB');
 ylabel('Bit Error Rate');

fprintf('\n\n Eb/N0 range (dB) : '); disp(EbN0dB);
fprintf(' Frame Error Rates: '); disp(FER);
fprintf(' Bit Error Rates  : '); disp(BER);

PCparams=PCparams1; %restore the original
end