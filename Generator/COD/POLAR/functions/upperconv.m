function llr=upperconv(llr1,llr2)
%
% *****PERFORMS IN LOG DOMAIN*****
% llr = (llr1*llr2 +1) / (llr1 + llr2)
%

llr = logdomain_sum(llr1+llr2,0) - logdomain_sum(llr1,llr2);
end