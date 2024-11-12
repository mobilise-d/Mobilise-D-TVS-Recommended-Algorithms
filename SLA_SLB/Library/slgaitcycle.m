


function [slgc_af]=slgaitcycle(slgc_bf,LHS)
    if size(slgc_bf,2) > size(slgc_bf,1)
        slgc_bf=slgc_bf';
    end
    
    if length(slgc_bf)<LHS
        slgc_af=[slgc_bf;repmat(nanmean(slgc_bf),LHS-length(slgc_bf),1)];
    else
        slgc_af=slgc_bf(1:LHS);
    end

end