function [results,all_clusters] = correspondance ( fpaths,max_overlap_time,overlap_time,Fs,remove_noise )

%% init
nFolders = length(fpaths);
all_clusters = cell(nFolders,1);
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    [results,all_clusters{i}] = run_match_clusters( fpath,remove_noise,max_overlap_time,Fs,overlap_time );
    clusters = all_clusters{i};

    save(fullfile(fpaths{i},'Clusters'),'clusters');
end