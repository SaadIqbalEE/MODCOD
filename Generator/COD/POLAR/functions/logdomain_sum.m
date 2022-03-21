function z=logdomain_sum(x,y)
%
if(x<y)
    z = y+log(1+exp(x-y));
else
    z = x+log(1+exp(y-x));
end
end