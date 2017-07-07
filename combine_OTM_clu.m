function combine_OTM_clu(fpath,clusters,overlap_step,max_time,Fs)
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
    
    
    idx = tmp_res > samples - overlap_step;
    tmp_res(~idx) = [];
    tmp_clu(~idx) = [];
    if samples == max_step
        new_res = tmp_res + i * overlap_step - max_step;
    else
        new_res = tmp_res;
    end
    new_clu = tmp_clu;
    %% replace current clu values with previous
    cur_clus = unique(clusters(:,i));
    cur_clus(cur_clus == 0) = [];
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
clu = [length(unique(clu)); clu];
dlmwrite(fullfile(fpath,'OLM.clu.2'),clu);
dlmwrite(fullfile(fpath,'OLM.res.2'),res,'precision',100);

return    
