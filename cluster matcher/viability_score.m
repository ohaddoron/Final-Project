function viability_score ( fpath, nchans, template_time_length,...
    clusters, post_process_clusters,max_overlap,Fs,overlap_step ) 
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
%% Cluster matching
    [results,~] = run_match_clusters( fpath ,true,max_overlap,Fs,overlap_step);
    for i = 1 : length(results)
        cur_matches = results{i}.matches(~isnan(results{i}.matches));
        for k = 1 : length(cur_matches)
            R = find(results{i}.matches == cur_matches(k));
            C = results{i}.matches(R);
            score = results{i}.n_match_score(R,C);
            idx = clusters(:,i+1) == C;
            S(idx,i+1,2) = score;
        end
        
            
%         idx2keep = clusters(logical(clusters(:,i+1)),i+1);
%         match_score = results{i}.n_match_score(:,idx2keep);
%         m = nanmax(match_score);
%         S(post_process_clusters(:,i+1) > 0,i+1,2) = m;
    end
    a = 1;    

%% Isolation distance and L-ratio
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
        % use only scores of relevant clusters
        ID = ID(templates_idx);
        L_ratio = L_ratio(templates_idx);
        % Place in score matrix
        S(post_process_clusters(:,i) > 0,i,1) = ID;
%         S(post_process_clusters(:,i) > 0,i,2) = L_ratio;
    end
%% plot scores
S(isnan(S)) = 0;
% find first occurence idx
tmp = S(:,:,1);
idx = zeros(size(tmp,1),1);
for i = 1 : size(tmp,1)
    try
        idx(i,1) = i;
        idx(i,2) = find(tmp(i,:),1);
    catch
        S(i,2) = 0;
        idx(i,1) = i;
        idx(i,2) = 2;
    end
end

    
return
    

