function [results,clusters] = correspondance ( fpaths,max_overlap_time,overlap_time,Fs,remove_noise )

%% init
nFolders = length(fpaths);
clusters = cell(nFolders,1);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    if i == 1
        [results,clusters{i}] = run_match_clusters( fpath,remove_noise,max_overlap_time,Fs,overlap_time );
        continue
    end
    tmp_clusters = clusters{i};
    save(fullfile(fpaths{i},'Clusters'),'tmp_clusters');
    [tmp_results,clusters{i}] = run_match_clusters( fpath,remove_noise,max_overlap_time,Fs,overlap_time );
    results = [results; tmp_results];
end