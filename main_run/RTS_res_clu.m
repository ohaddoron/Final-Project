function RTS_res_clu(fpaths,offset_val,overlap_step,max_time,Fs,clusters,template_time_length,n_spikes_threshold)
%% init
nFolders = length(fpaths);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    outpath = fullfile(fpath,'RTS');
    if ~exist(outpath,'dir')
        mkdir(outpath);
    end
    create_RTS_clu_res(fpath,offset_val,overlap_step,max_time,Fs,clusters{i},template_time_length,n_spikes_threshold,outpath);
end
return