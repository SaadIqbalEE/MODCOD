frameLen = 512; % Frame length
s = RandStream('mt19937ar', 'Seed', 11);
intrlvrIndices = randperm(s, frameLen);
turboenc = comm.TurboEncoder('InterleaverIndices', intrlvrIndices);
path = strcat('/home/user12/Saad_External/COD_DATASET/TURBO_DATASET.h5');
h5create(path,'/DATA',[154800 Inf],'ChunkSize',[154800 1]);

counter_file = 1;
for j=1:10000
    counter = 1;
    dataset = zeros(102400, 1);    
    for i= 1:100
        %%%%%%%%%%%%%% Random Generator %%%%%%%%%%%%%
        %%% Generating a Pkt of 1296 bits %%%

        % 64 character string generated!
        pkt = randi(255, 64, 1);

        % converting it into stream of bits
        out = dec2bin(pkt,8);
        info_bits = reshape(out(:,:)'-'0',1,[]);

        encData = turboenc(info_bits');
        
        dataset(counter:counter+1547)=encData;
        counter = counter + 1548;
    end
        start = [1 counter_file];
        count = [154800 1];
        h5write(path,'/DATA',dataset,start,count);
        counter_file = counter_file+1;
end
h5disp('Turbo2.h5');