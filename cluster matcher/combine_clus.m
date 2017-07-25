new_clusters = clusters;
% new_clusters(sum(new_clusters > 0,2)==0,:) = [];
new_clusters(sum(new_clusters > 0 ,2) <=1,:) = [];
tmp_clusters = new_clusters;
for i = 1 : size(tmp_clusters,1)
    tmp_clusters(i,tmp_clusters(i,:) > 0) = i;
end
% max_overlap = 30;
overlap_step = 10;
Fs = 20e3;
count = 1;
% new_RTS_clu = zeros(sum(cellfun(@length,RTS_clu)),1);
new_RTS_clu = [];
new_RTS_res = [];
% count = 1;
for j = 1 : size(new_clusters,2)
    overlap = (j-1) * overlap_step * Fs * 60;

    clu = RTS_clu{j};
    res = RTS_res{j};
    new_clu = zeros(length(clu),1);
    new_res = zeros(length(clu),1);
    for i = 1 : size(new_clusters,1)
        if new_clusters(i,j) > 0
            
            idx = clu == new_clusters(i,j);
            new_clu(idx) = tmp_clusters(i,j);
            new_res = res(idx);
%             count = count+1;
        end
%         idx = new_clu == count;
        new_RTS_clu = [new_RTS_clu; new_clu(idx)];
        new_RTS_res = [new_RTS_res; new_res + overlap];
        
    end
end

[new_RTS_res,I] = sort(new_RTS_res);
new_RTS_clu = new_RTS_clu(I);
        