function viability_score ( fpath, nchans, template_time_length,  clusters, post_process_clusters ) 
% The viavility score is a score given to each cluster as it appears. The
% role of the viability score is to asses apriori for how long is the
% cluster going to be stable for. Clusters with high scores, will last
% longer than others
%% init
folders = dir(fpath);
folders(1:2) = [];
folders(~[folders.isdir]) = [];
nFolders = length(folders);
fnames = cell2mat(cellfun(@str2num,{folders.name},'UniformOutput',false));
ordered_names = sort(fnames);
clusters(sum(clusters,2) == 0,:) = [];
S = nan([size(post_process_clusters),2]);
%% cycle through folders and calculate stats
for i = 1 : nFolders
    % Analyze the results of the KS run and extract stats
    path = fullfile(fpath,sprintf('%d',ordered_names(i)));
    load(fullfile(path,'templates.mat'));
    % Get idx of templates that are not noise
    templates_idx = noise_remover(merged_templates);
    [~,L_ratio,ID] = PCA_analysis...
        (path,nchans,template_time_length,0,'KS',[],[]);
    % If any of the clusters were not assigned any spikes to, the ID will
    % be zero. This is of no intereset to us.
%     if max(templates_idx) > length(ID)
%         flag = 1;
%     end
%     ID(ID == 0) = nan;
    % use only scores of relevant clusters
    ID = ID(templates_idx);
    L_ratio = L_ratio(templates_idx);
    % Place in score matrix
    S(post_process_clusters(:,i) > 0,i,1) = ID;
    S(post_process_clusters(:,i) > 0,i,2) = L_ratio;
end
%% plot scores
S(isnan(S)) = 0;
% viability vs ID
[~,ID_scores] = find(S(:,:,1));
figure,  



return
    
