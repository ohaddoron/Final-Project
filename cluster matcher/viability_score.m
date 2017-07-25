function viability_score ( fpath,max_overlap,Fs,overlap_step ) 
% The viavility score is a score given to each cluster as it appears. The
% role of the viability score is to asses apriori for how long is the
% cluster going to be stable for. Clusters with high scores, will last
% longer than others
%% init
% folders = dir(fpath);
% folders(1:2) = [];
% folders(~[folders.isdir]) = [];
% nFolders = length(folders);
% fnames = cell2mat(cellfun(@str2num,{folders.name},'UniformOutput',false));
% % ordered_names = sort(fnames);
% % clusters(sum(clusters,2) == 0,:) = [];
% S = nan([size(post_process_clusters),2]);
% % origin = 1;
% % clusters2remove = [{0},{0}];

%% cycle through folders and calculate stats
% for i = 1 : nFolders - 1
%     % set paths
%     path1 = fullfile(fpath,sprintf('%d',ordered_names(i)));
%     path2 = fullfile(fpath,sprintf('%d',ordered_names(i+1)));
%     path = [{path1},{path2}];
%     % Get idx of templates that are not noise
%     load(fullfile(path1,'templates.mat'));
%     templates2keep{1} = noise_remover(merged_templates);
%     load(fullfile(path2,'templates.mat'));
%     templates2keep{2} = noise_remover(merged_templates);
%     
%     result = match_clusters4(path,clusters2remove,origin,templates2keep,ovelap1,overlap2,
%     
%     % Analyze the results of the KS run and extract stats
%     [~,L_ratio,ID] = PCA_analysis...
%         (path,nchans,template_time_length,0,'KS',[],[]);
%     % If any of the clusters were not assigned any spikes to, the ID will
%     % be zero. This is of no intereset to us.
%     % use only scores of relevant clusters
%     ID = ID(templates_idx);
%     L_ratio = L_ratio(templates_idx);
%     % Place in score matrix
%     S(post_process_clusters(:,i) > 0,i,1) = ID;
%     S(post_process_clusters(:,i) > 0,i,2) = L_ratio;
% end
[results,clusters] = run_match_clusters( fpath ,true,max_overlap,Fs,overlap_step);
%% plot scores
S(isnan(S)) = 0;
% find first occurence idx
[r,c]=find(S(:,:,1)>0);
idx=sortrows([r,c]);
ix=[true;diff(idx(:,1))~=0];
idx = idx(ix,:);
idx = sub2ind(size(S(:,:,1)),idx(:,1),idx(:,2));
return
    

