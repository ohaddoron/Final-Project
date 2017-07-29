function [results,clusters] = run_match_clusters( fpath ,remove_noise_spikes, varargin)
% run match clusters will cycle through all partitions of files and create
% the clusters matrix. The clusters matrix maps the cluster index from one
% frame to the next. In addition, the results structure will be return
% containing information regarding the decisions made for the cluster
% matrix
%% init
if isempty(varargin)
    max_overlap = 30; %min - maximal overlap between files
    Fs = 20e3; % min - sampling rate
    overlap_step = 10; % min - overlap increase
else
    max_overlap = varargin{1};
    Fs = varargin{2};
    overlap_step = varargin{3};
end
if length(varargin) > 3
    thresh = varargin{4};
else 
    thresh = 1000;
end
files = dir(fpath);
names = {files.name};
fnames = cellfun(@str2num,names,'UniformOutput',false);
idx = ~cellfun(@isempty,fnames);
files = files(idx);
fnames = cell2mat(cellfun(@str2num,{files.name},'UniformOutput',false));
ordered_names = sort(fnames);
nFolders = length(ordered_names);
clusters2remove = {0,0};
nchans = 8;
template_time_length = 82;
origin = 1;
results = cell(nFolders-1,1);
%% main
for i = 2 : nFolders
    %% set paths to previous and current folder
    cur_path{1} = fullfile(fpath,sprintf('%d',ordered_names(i-1)));
    cur_path{2} = fullfile(fpath,sprintf('%d',ordered_names(i)));
    
    %% set overlaps used
    if i-1 <= max_overlap / overlap_step
        overlap1 = 0;
    else
        overlap1 = min([(i-2) * overlap_step, overlap_step]);
    end
    overlap2 = min([max_overlap,(i-1) * overlap_step]);
    
    %% remove noisy spikes
    load(fullfile(cur_path{1}, '\templates.mat'));
    merged_templates1 = merged_templates;
    load(fullfile(cur_path{2},'templates.mat'));
    merged_templates2 = merged_templates;

    if remove_noise_spikes
        templates2keep{1} = noise_remover(merged_templates1);
        templates2keep{2} = noise_remover(merged_templates2);
        
        files1 = dir(cur_path{1});
        files2 = dir(cur_path{2});
        
        clu1_idx = ~cellfun(@isempty,strfind({files1.name},'.clu.2'));
        res1_idx = ~cellfun(@isempty,strfind({files1.name},'.res.2'));
        
        res2_idx = ~cellfun(@isempty,strfind({files2.name},'.res.2'));
        clu2_idx = ~cellfun(@isempty,strfind({files2.name},'.clu.2'));

        path2clu1 = fullfile(cur_path{1},files1(clu1_idx).name);
        path2res1 = fullfile(cur_path{1},files1(res1_idx).name);

        path2clu2 = fullfile(cur_path{2},files2(clu2_idx).name);
        path2res2 = fullfile(cur_path{2},files2(res2_idx).name);
        
        [clu1,res1] = load_clu_res(path2clu1,path2res1,0);
        clu1(~ismember(clu1,templates2keep{1})) = [];
        [clu2,res2] = load_clu_res(path2clu2,path2res2,0);
        clu2(~ismember(clu2,templates2keep{2})) = [];
        for k = 1 : max(unique(clu1))
            if sum(clu1 == k) < thresh && sum(clu1 == k) > 0
                templates2keep{1}(templates2keep{1} == k) = [];
            end
        end
        for k = 1 : max(unique(clu2))
            if sum(clu2 == k) < thresh && sum(clu2 == k) > 0
                templates2keep{2}(templates2keep{2} == k) = [];
            end
        end
                

        
    else
        templates2keep = cell(2,1);
    end
    nTemplates1 = size(merged_templates1,3);
    nTemplates2 = size(merged_templates2,3);

    [results{i-1}]=match_clusters4( cur_path,clusters2remove,origin,...
        templates2keep,overlap1,overlap2,Fs,1000,0.6);
    results{i-1}.templates2keep = templates2keep;

    if i == 2
        clusters = (1:nTemplates1)';        
        prev = 1:nTemplates2;
    else
        prev = clusters(:,end);
    end
    
    matches = ~isnan(results{i-1}.matches);
    idx = find(matches);
    [~,idx3] = intersect(prev,idx);
    clusters(idx3,end+1) = results{i-1}.matches(idx);
    
    idx2 = find(~ismember(1:nTemplates2,results{i-1}.matches(idx)));
    tmp = zeros(length(idx2),size(clusters,2));
    tmp(:,end) = idx2;
    clusters = [clusters; tmp];
    
    if i == 2
        idx2remove1 = ~ismember(clusters(:,1),templates2keep{1});
        clusters(idx2remove1,1) = 0;
    end
    idx2remove2 = find(~ismember(1:nTemplates2,templates2keep{2}));
    clusters(ismember(clusters(:,end),idx2remove2),end) = 0;
end
% results.clusters = clusters;
end

