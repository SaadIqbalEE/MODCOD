function i = bitreversed(j,n)
% Consider an "n" bit representation of "j" and
% reverse the order of bits to get "i"

i=zeros(length(j),1);

for indx=1:length(j)
i(indx) = bin2dec(wrev(dec2bin(j(indx),n)));
end
% dec2bin() : produces a string of binary form of "j" in at least "n" bits
% wrev()    : produces a reversed string (here again a binary string)
% bin2dec() : binary "string" to decimal conversion

end
