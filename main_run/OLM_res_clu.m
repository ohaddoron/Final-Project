function post_process_clusters = OLM_res_clu ( fpaths,clusters, overlap_time,max_time,Fs )

%% init
nFolders = length(fpaths);
post_process_clusters = cell(nFolders,1);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    outpath = fullfile(fpath,'OLM');
    if ~exist(outpath,'dir'); mkdir(outpath); end
    post_process_clusters{i} = combine_OTM_clu ( fpath, clusters{i} ,overlap_time, max_time, Fs,outpath);
end