function all_post_process_clusters = OLM_res_clu ( fpaths,clusters, overlap_time,max_time,Fs )

%% init
nFolders = length(fpaths);
all_post_process_clusters = cell(nFolders,1);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    outpath = fullfile(fpath,'OLM');
    if ~exist(outpath,'dir'); mkdir(outpath); end
    all_post_process_clusters{i} = combine_OTM_clu ( fpath, clusters{i} ,overlap_time, max_time, Fs,outpath);
    post_process_clusters = all_post_process_clusters{i};
    save(fullfile(fpaths{i},'post_process_clusters'),'post_process_clusters');
end
all_post_process_clusters = cat(1,all_post_process_clusters);
return