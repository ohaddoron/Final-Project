function [ life_time ] = clc_life_time( post_process_clusters )
% return the start & end of every cluster in post_process_clusters in 2 cloume format
for i=1:size(post_process_clusters,1)
    tmp=post_process_clusters(i,:);
    life_time(i,1)= min(find(tmp~=0));
    life_time(i,2)= max(find(tmp~=0));
end
end

