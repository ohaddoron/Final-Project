function split_times (fpaths,nchans,nchans_tot,overlap_time,max_overlap_time,Fs)


%% initilization
nPaths = length(fpaths);
nbytes = 2;
%% cycle through paths
for i = 1 : nPaths
    %% init
    cur_path = fpaths{i};
    info = dir(fullfile(cur_path,'*.dat'));
    nsamples = info.bytes / nbytes / nchans(i);
    overlap_step = overlap_time * Fs(i) * 60;
    max_overlap = max_overlap_time * Fs(i) * 60;
    count = 1;
    %% split
    periods = [1 overlap_step];
    
    while max(periods(:)) < nsamples
        if count * overlap_step < max_overlap
            count = count + 1;
            periods(end+1,:) = [1, count * overlap_step];
            continue
        end
        count = count + 1;
        periods(end+1,:) = [count * overlap_step, count*overlap_step + max_overlap];
    end
    partition( sourcefile, [], periods, nchans, 'int16' )
    
end
    
    
    