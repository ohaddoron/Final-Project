function split_times (paths,nchans,nchans_tot,overlap_time,max_overlap_time,Fs)


%% initilization
nPaths = length(paths);
nbytes = 2;
fpaths = {};
%% cycle through paths
for i = 1 : nPaths
    %% init
    cur_path = paths{i};
    info = dir(fullfile(cur_path,'*.dat'));
    sourcefile = fullfile(cur_path,info.name);
    nsamples = info.bytes / nbytes / nchans;
    overlap_step = overlap_time * Fs * 60;
    max_overlap = max_overlap_time * Fs * 60;
    count = 1;
    count2 = 1;
    %% split
    periods = [1 overlap_step];
    
    while max(periods(:)) < nsamples
        if count * overlap_step < max_overlap
            count = count + 1;
            periods(end+1,:) = [1, count * overlap_step];
            continue
        end
        
        periods(end+1,:) = [count2 * overlap_step, count2*overlap_step + max_overlap];
        count2 = count2 + 1;
    end
    [~,newfiles] = partition( sourcefile, [], periods, nchans, 'int16' );
    for k = 1 : length(newfiles)
        path = fullfile(cur_path,sprintf('%d',k));
        if ~exist(path,'file')
            mkdir(path);
        end
        [~,name,ext] = fileparts(newfiles{k});
        movefile(newfiles{k},fullfile(path,strcat(name,ext)));
    end
    
end
    
    
    