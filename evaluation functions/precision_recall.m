function [P,R] = precision_recall ( hits )

%% Constants
[N_cluster1,N_cluster2] = size(hits);
N_pairs = N_cluster1 * (N_cluster1 - 1) /2; 

%% TP_FP
spikes_in_clu2 = sum(hits,1);

TP_FP = 0;
for i = 1 : N_cluster2
    if spikes_in_clu2(i) > 1
        TP_FP = nchoosek(spikes_in_clu2(i),2) + TP_FP;
    end    
end


%% TP
TP = 0;
for j = 1 : N_cluster2 
    for i = 1 : N_cluster1
        if hits(i,j) >= 2
            TP = TP + nchoosek(hits(i,j),2);
        end
    end
end
 
%% FP 

FP = TP_FP - TP;

%% FN

FN = 0; 
for i =1 : N_cluster1
    for j = 1 : N_cluster2
        FN = FN + hits(i,j) * sum(hits(i,j+1:end));
    end
end
    

%% TN

TN = N_pairs - TP - FP - FN;


%% P,R
P = TP/(TP+FP);
R = TP/(TP+FN);

