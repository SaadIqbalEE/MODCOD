function updateLLR(i)
% PCparams structure is implicit parameter
%
% Non-Recursive implementation of the SCD update Likelihoods routine
%

global PCparams;

n = PCparams.n;


if i==1
    nextlevel=n;
else
    %%%%%%TO IMPROVE LATER%%%%%%%%%
      %FINDING FIRST INDEX OF '1'
    i_bin = dec2bin(i-1,n);
    for lastlevel = 1:n
        if i_bin(lastlevel) == '1'
            break;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%% Initialize with lowerconv() %%%%%%
        st = 2^(lastlevel-1);
        ed = 2^(lastlevel) -1;
        for indx = st:ed
            PCparams.LLR(indx) = lowerconv(...
                           PCparams.BITS(1,indx), ...
                           PCparams.LLR(ed+2*(indx-st)+1), ...
                           PCparams.LLR(ed+2*(indx-st)+2) ...
                           );
        end
        nextlevel = lastlevel-1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Proceed upwards the TREE, with upperconv() till ROOT node
for lev = nextlevel :-1: 1
    st = 2^(lev-1);
    ed = 2^lev - 1;
    for indx = st:ed
        PCparams.LLR(indx) = upperconv(PCparams.LLR(ed+2*(indx-st)+1), ...
                       PCparams.LLR(ed+2*(indx-st)+2));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end