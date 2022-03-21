%%%% Polar Encoding Generator
N=1024; K=512; Ec=1; N0=2; %0dB SNR
initPC(N,K,Ec,N0);

path = strcat('/home/user12/Saad_External/COD_DATASET/POLAR_DATASET.h5');

h5create(path,'/DATA',[102400 Inf],'ChunkSize',[102400 1]);
counter_file = 1;
for j=1:10000
    counter = 1;
    dataset = zeros(102400, 1);
    for i=1:100
        %%%%%%%%%%%%%% Random Generator %%%%%%%%%%%%%
        %%% Generating a Pkt of 512 bits %%%

        % 64 character string generated!
        pkt = randi(255, 64, 1);

        % converting it into stream of bits
        out = dec2bin(pkt,8);
        info_bits = reshape(logical(out(:,:)'-'0'),1,[]);
        x= pencode(info_bits); % POLAR ENCODING
        
        DataSet(counter:counter+1023,1) = x;
        counter = counter + 1024;
    end
    start = [1 counter_file];
    count = [102400 1];
    h5write(path,'/DATA',DataSet,start,count);
    counter_file = counter_file + 1;
end