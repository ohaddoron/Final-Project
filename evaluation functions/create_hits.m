function hits = create_hits (analysis1,analysis2)


cluster_labels1 = unique(analysis1(:,1));
cluster_labels2 = unique(analysis2(:,1));
N_cluster1 = length(cluster_labels1);
N_cluster2 = length(cluster_labels2);


hits = zeros(max(cluster_labels1),max(cluster_labels2));

for i=1:N_cluster1
    for j=1:N_cluster2
        hits  (cluster_labels1(i),cluster_labels2(j))=sum((analysis1(:,1)==cluster_labels1(i)    &   ...
            analysis1(:,2)==cluster_labels2(j)));
    end
end

cluster0 = zeros(1,max(cluster_labels2));
for j = 1 : N_cluster2 
    cluster0(cluster_labels2(j)) = sum(analysis2(:,2)==0 & analysis2(:,1) == cluster_labels2(j));
end

hits = cat(1,cluster0,hits);


cluster1 = zeros(max(cluster_labels1)+1,1);
for i = 1 : N_cluster1 
    cluster1(cluster_labels1(i)+1) = sum(analysis1(:,2)==0 & analysis1(:,1) == cluster_labels1(i));
end

hits = cat(2,cluster1,hits);
% the first row is spikes found in res2 but ARE NOT found in res1