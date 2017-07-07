function [ all_clusters,h ] = run_run_matcher( folders )

n_folders=length(folders);
all_clusters=cell(2*n_folders,1);
for i=1:n_folders
    
    all_clusters{2*i-1} = run_match_clusters( folders{i} ,0);
    [h{2*i-1},b{2*i-1}]=hist(sum(all_clusters{2*i-1}~=0,2),0:20);
    all_clusters{2*i} = run_match_clusters( folders{i} ,1);
    [h{2*i},b{2*i}]=hist(sum(all_clusters{2*i}~=0,2),0:20);
    [~ , folder_name , ~ ]=fileparts(folders{i});
    figure(99);
    subplot( n_folders,2,2*i-1);
    bar(b{2*i-1},h{2*i-1});
    title([ folder_name sprintf('\n No noise removal')]);
    subplot( n_folders,2,2*i);
    bar(b{2*i},h{2*i});
    title([ folder_name sprintf('\n With noise removal')]);
end
end

