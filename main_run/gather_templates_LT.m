function [templates,LT] = gather_templates_LT ( fpaths )

%% init
nShanks = length(fpaths);
templates = cell(nShanks,1);
post_process_clusters = cell(nShanks,1);
%%
for i = 1 : nShanks
    %%
    fpath = fpaths{i};
    files = dir(fpath);
    files(1:2) = [];
    files(~[files.isdir]) = [];
    idx = isstrprop({files.name},'digit');
    idx2remove = cellfun(@sum,idx) == 0;
    files(idx2remove) = [];
    names = cellfun(@str2num,{files.name});
    nTimes = length(names);
    tmp = load(fullfile(fpath,'Clusters.mat'));
    clusters = tmp.clusters;
    tmp = load(fullfile(fpath,'post_process_clusters.mat'));
    post_process_clusters{i} = tmp.post_process_clusters;
    %%
    for k = 1 : nTimes
        cur_path = fullfile(fpath,files(names == k).name);
        path2template = fullfile(cur_path,'templates.mat');
        load(path2template);
        templates_idx = unique(clusters(:,k));
        templates_idx(templates_idx == 0) = [];
        
        
        merged_templates = merged_templates(:,:,templates_idx);
        templates{i} = cat(3,templates{i},merged_templates);
        clusters(ismember(clusters(:,k),templates_idx),:) = [];
    end
    
end
templates = cat(3,templates{:});
post_process_clusters = cat(1,post_process_clusters{:});
LT = sum(post_process_clusters > 0 ,2);
return 

        
    
    