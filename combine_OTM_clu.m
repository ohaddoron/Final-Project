function combine_OTM_clu(fpath,clusters,overlap_step,max_time,Fs)
    %% init
    overlap_step = overlap_step * 60 * Fs; 
    max_step = max_time * 60 * Fs; % maximal time in samples
    clusters(sum(clusters,2)==0,:) = []; % remove zero lines
    folders = dir(fpath);
    folders(1:2) = [];
    folders([~folders.isdir]) = [];
    fnames = cell2mat(cellfun(@str2num,{folders.name},'UniformOutput',false));
    ordered_names = sort(fnames);
    
    cur_path = fullfile(fpath,sprintf('%d',ordered_names(1)));
    residx = ~cellfun(@isempty,strfind({files.name},'res.'));
    cluidx = ~cellfun(@isempty,strfind({files.name},'clu.'));
    
    %% main loop
    for i = 1 : length(ordered_names)
        %% get clu and res idx
        cur_path = fullfile(fpath,sprintf('%d',ordernames(i)));
        files = dir(cur_path,'*.2');
        residx = ~cellfun(@isempty,strfind({files.name},'res.'));
        cluidx = ~cellfun(@isempty,strfind({files.name},'clu.'));
        path2res = fullfile(cur_path,files(residx).name);
        path2clu = fullfile(cur_path,files(cluidx).name);
        
        %% load the new clu and res
        % in case this is the first iteration, simply add the current clu
        % and res
        if i == 1
            [clu,res] = load_clu_res (path2clu, path2res , 0);
            continue
        end
        [tmp_clu,tmp_res] = load_clu_res (path2clu, path2res , 0);
        % use only the last overlap step to avoid overlap
        samples = min(i * overlap_step, max_step);
        idx = tmp_res(tmp_res > samples - overlap_step);
        tmp_res(~idx) = [];
        tmp_clu(~idx) = [];
        
        cur_clus = unique(clusters(:,i));
        %% replace current clu values with previous
        for k = 1 : length(cur_clus)
            idx = cur_clus == cur_clus(k);
            tmp_clu(tmp_clu == cur_clus(k)) = clusters(idx,i-1);
        end
        %% add overlap to res
        
        
        
        


        
        

        

    end
    
    
    