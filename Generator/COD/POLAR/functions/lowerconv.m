function llr = lowerconv(upperdecision, upperllr, lowerllr)
%
% *****PERFORMS IN LOG DOMAIN****
% llr = lowerllr * upperllr  -- if uppperdecision == 0
% llr = lowerllr / upperllr  -- if uppperdecision == 1
%

if upperdecision==0
    llr = lowerllr + upperllr;
else
    llr = lowerllr - upperllr;
end

end