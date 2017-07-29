function OLM_res_clu ( fpaths,clusters, overlap_time,max_time,Fs )

%% init
nFolders = length(fpaths);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    combine_OTM_clu ( fpath, clusters{i} ,overlap_time, max_time, Fs);
end