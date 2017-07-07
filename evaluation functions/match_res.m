function [TP,FP] = match_res( res1 , res2, offset )

% res1 is considered the original ground truth and res2 is compared
TP = 0;
FP = ones(length(res2),1);
for l = -offset:offset
    TP = TP + sum(ismember(res1+l,res2));
    FP(ismember(res2,res1+l)) = 0;
end

TP = TP/length(res1);
FP = sum(FP) / length(res2);
