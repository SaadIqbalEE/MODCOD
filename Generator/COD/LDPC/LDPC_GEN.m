clc;
close all;

ldpc_code = LDPCCode(0, 0);

%%% LDPC Data Generation %%%
%%% 1M samples for 1/2, 2/3, 3/4, 5/6 codes with block length 1296%%%
block_length = 1296; % Should be one of 648, 1296, and 1944

CR = [1/2,2/3,3/4,5/6];
CR_label = ['12';'23';'34';'56'];

samples = 2500; 
path = strcat('/home/user12/Saad_External/COD_DATASET/LDPC_DATASET.h5');
%h5create(path,'/DATA',[129600 Inf],'Datatype','double','ChunkSize',[1296 1]);
%h5create(path,'/CODERATE',[1 Inf],'Datatype','double','ChunkSize',[1 1]);

counter_file = 2501;

for i=2:length(CR)
    rate = CR(i); % Should be one of 1/2, 2/3, 3/4, 5/6
    ldpc_code.load_wifi_ldpc(block_length, rate);

    info_length = ldpc_code.K;
    DataSet = zeros(129600,1);
    for samp = 1:samples
        counter = 1;
        for inner_loop = 1:100
            %%%%%%%%%%%%%% Random Generator %%%%%%%%%%%%%
            %%% Generating a Pkt of 1296 bits %%%

            % 162 character string generated!
            pkt = randi(255, ceil(info_length/8), 1);

            % converting it into stream of bits
            out = dec2bin(pkt,8);
            info_bits = reshape(logical(out(:,:)'-'0'),1,[]);
            coded_bits = ldpc_code.encode_bits(info_bits(1,1:info_length));
            DataSet(counter:counter+1295) = coded_bits;
            counter = counter +1296;
        end
        start = [1 counter_file];
        count = [129600 1];
        h5write(path,'/DATA' ,DataSet,start,count);
        h5write(path,'/CODERATE' ,i,[1 counter_file],[1 1]);
        counter_file = counter_file + 1;
    end
end
h5disp('LDPC.h5');