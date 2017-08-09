function results = compare_OLM_RTS_wrapper ( fpaths,offset,post_process_clusters,...
    Fs,overlap_step,nchans,clusters2remove,template_time_length )

%% init
nFolders = length(fpaths);
results = cell(nFolders,1);
%% main
for i = 1 : nFolders
    path = fpaths{i};
    OLM_path = fullfile(path,'OLM');
    RTS_path = fullfile(path,'RTS');
    files = dir(fullfile(path,'Full'));
    idx = contains({files.name},'temp_wh.dat');
    path2dat = fullfile(path,'Full',files(idx).name);
    results{i} = compare_OLM_RTS (OLM_path,RTS_path,offset,[],post_process_clusters{i},...
        Fs,overlap_step,nchans,clusters2remove,template_time_length,...
        path2dat);
end
results = cat(1,results{:});
return