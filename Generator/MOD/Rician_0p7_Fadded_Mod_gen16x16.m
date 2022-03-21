clear all;
clc;

%Modulations Schemes are BPSK, QPSK, PSK8, PSK16, PSK32, QAM16 & QAM32
%SNR: -4:2:14
% The Sample Rate is fixed: 1024
% Samples/Symbol: 16 implies "64 Symbols per second"
% Block Length: 256... 1/4 of a Second

Mod_scheme = ['BPSK_';'QPSK_';'PSK8_';'PSK16';'QAM16';'QAM32'];
M_order = [2 4 8 16 16 32];
SNR = -4:2:14;
snrx= 10.^(-SNR/10);                  %No

% 16 samples per symbol
Sym_per_Sec = 64;
sample_rate = 1024;
BPSKMod = comm.BPSKModulator;
QPSKMod = comm.QPSKModulator('BitInput',true);
PSK8Mod = comm.PSKModulator(8,'BitInput',true);
PSK16Mod = comm.PSKModulator(16,'BitInput',true);

filt = comm.RaisedCosineTransmitFilter('RolloffFactor',0.35,'FilterSpanInSymbols',4,'OutputSamplesPerSymbol', 16);
b = coeffs(filt);
filt.Gain = 1/max(b.Numerator);

for dataset = 1
    out = [];
    path = strcat('/home/user12/Saad_External/MODCOD_DataSet/MOD_DATASET/MOD_Rician0p7fadded_16Samp_N',num2str(dataset),'.h5');
    h5create(path,'/DATA',[4 256 Inf],'Datatype','double','ChunkSize',[4 256 1]);
    h5create(path,'/SNR',[1 Inf],'Datatype','double','ChunkSize',[1 1]);
    h5create(path,'/DATATYPE',[1 Inf],'Datatype','double','ChunkSize',[1 1]);
    counter = 1;
    for sel_mod = 1:length(Mod_scheme)  
        for i= 1:25
            DataSet = zeros(4,256,4000);
            SNR_data = zeros(1,4000);
            mod_data = zeros(1,4000);
            D_counter = 1;
                for sel_SNR = 1:length(SNR)
                    frame_len = Sym_per_Sec*log2(M_order(sel_mod))*101;
                    bits = randi([0 1],frame_len,1);
                    k = Mod_scheme(sel_mod,:);

                    switch (k)
                        case 'BPSK_'
                            out = BPSKMod(bits);
                        case 'QPSK_'
                            out = QPSKMod(bits).*sqrt(2);
                        case 'PSK8_'
                            out = PSK8Mod(bits).*sqrt(3);
                        case 'PSK16'
                            out = PSK16Mod(bits).*sqrt(4);            
                        case 'QAM16'
                            stream = reshape(bits,Sym_per_Sec*101,log2(M_order(sel_mod)));
                            out = qammod(bi2de(stream),16)./(sqrt(5/2));
                        case 'QAM32'
                            stream = reshape(bits,Sym_per_Sec*101,log2(M_order(sel_mod)));
                            out = qammod(bi2de(stream),32)./(sqrt(4));
                    end
                    stream = filt(out);
                    No_floor = (sqrt(snrx(sel_SNR))/2)*(randn(102400,1) + 1i*randn(102400,1));
                    SD = 1/sqrt(2);
                    H=(normrnd(0.8367,SD,[102400 1])+1i*normrnd(0.8367,SD,[102400 1]));
                    Rec = stream(512:length(stream)-513).*H + No_floor;
                    peak_data = max(abs(Rec));

                    amp = abs(Rec)./peak_data;
                    pha = (rem(phase(Rec),pi)./(2*pi)) + 0.5;

                    Y = (Rec.*(1/(2*peak_data))) + (0.5+0.5j);
                    
                    

                    DataSet(1,:,D_counter:D_counter+399) = reshape(real(Y),[256,1,400]);	%R_reshape;
                    DataSet(2,:,D_counter:D_counter+399) = reshape(imag(Y),[256,1,400]);    %I_reshape;
                    DataSet(3,:,D_counter:D_counter+399) = reshape(amp,[256,1,400]);	%amp_reshape;
                    DataSet(4,:,D_counter:D_counter+399) = reshape(pha,[256,1,400]);	%phas_reshape;
                    
                    SNR_data(1,D_counter:D_counter+399) = SNR(sel_SNR)*ones(1,400);
                    mod_data(1,D_counter:D_counter+399) = (sel_mod -1)*ones(1,400);

                    D_counter = D_counter + 400;
                end            
 
            start = [1 1 counter];
            count = [4 256 4000];

            display_stuff = [dataset sel_mod i]; 
            disp(display_stuff)
            h5write(path,'/DATA' ,DataSet,start,count);
            h5write(path,'/SNR' ,SNR_data,[1 counter],[1 4000]);
            h5write(path,'/DATATYPE' ,mod_data,[1 counter],[1 4000]);
            counter = counter + 4000;
        end
    end
end
h5disp(path);