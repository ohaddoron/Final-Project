function post_process_clusters = combine_OTM_clu(fpath,clusters,overlap_step,max_time,Fs,varargin)
%% Input
% fpath - path to folders
% Fs is given in Hz
% clusters matrix - a matrix that indexes cluster # between file i and i+1.
% It is the output of run_match_clusters
% overlap_step - non-overlaping part of .dat files in minutes
%max_time - max .dat. file size in minutes
%% Output
% The function writes the new combined clu file and outputs the new
% clusters file
%% init
overlap_step = overlap_step * 60 * Fs; 
max_step = max_time * 60 * Fs; % maximal time in samples
clusters(sum(clusters,2)==0,:) = []; % remove zero lines
folders = dir(fpath);
folders(1:2) = [];
folders(~[folders.isdir]) = [];
fnames = cell2mat(cellfun(@str2num,{folders.name},'UniformOutput',false));
ordered_names = sort(fnames);
clu = [];
res = [];
count = 0;
if ~isempty(varargin)
    outpath = varargin{1};
else
    outpath = fpath;
end
% figure, hold on;

%% main loop
for i = 1 : length(ordered_names)
    %% get clu and res idx
    cur_path = fullfile(fpath,sprintf('%d',ordered_names(i)));
    files = dir(fullfile(cur_path,'*.2'));
    residx = ~cellfun(@isempty,strfind({files.name},'res.'));
    cluidx = ~cellfun(@isempty,strfind({files.name},'clu.'));
    path2res = fullfile(cur_path,files(residx).name);
    path2clu = fullfile(cur_path,files(cluidx).name);

    %% load the new clu and res
    
    [tmp_clu,tmp_res] = load_clu_res (path2clu, path2res , 0);
    % use only the last overlap step to avoid overlap
    samples = min(i * overlap_step, max_step);
    % remove spikes that came out of noisy clusters
    idx = ~ismember(tmp_clu,clusters(:,i));
    tmp_clu(idx) = [];
    tmp_res(idx) = [];
    
    %take only non-overlap part
    idx = tmp_res > samples - overlap_step;
    tmp_res(~idx) = [];
    tmp_clu(~idx) = [];
    
    % Every res file begins from the relative zero. We add this relative
    % zero to every res file
    if samples == max_step
        new_res = tmp_res + i * overlap_step - max_step;
    else
        new_res = tmp_res;
    end
    new_clu = tmp_clu;
    %% replace current clu values with previous
    cur_clus = unique(clusters(:,i));
    cur_clus(cur_clus == 0) = [];
    if length(cur_clus) ~= length(unique(new_clu))
        count = count + 1;
    end
    for k = 1 : length(cur_clus)
        new_clu(tmp_clu == cur_clus(k)) = find(clusters(:,i) == cur_clus(k));
    end
    tmp = (1 : size(clusters,1))';
    tmp(~logical(clusters(:,i))) = 0;
    clusters(:,i) = tmp;
    
    
    
    %% add overlap to res
%     plot(new_res,ones(length(tmp_res),1),'.'); drawnow;
    
    clu = [clu; new_clu];
    res = [res; new_res];
%     m = max(clu);
end
post_process_clusters = clusters;
clu = [length(unique(clu)); clu];
dlmwrite(fullfile(outpath,'OLM.clu.2'),clu);
dlmwrite(fullfile(outpath,'OLM.res.2'),res,'precision',100);

return    
