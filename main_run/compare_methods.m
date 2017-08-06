function results = compare_methods ( fpaths,samples_offset,post_process_clusters )

%% init
nFolders = length(fpaths);
results = cell(nFolders,1);
thresh = 0; % Isolation distance threshold. This is set to 0 and can be modified later on
%% cycle through shanks
for i = 1 : nFolders
    fpath = fpaths{i};
    %% KS to OLM
    path1 = fullfile(fpath,'KS');
    path2 = fullfile(fpath,'OLM');
    [results{i}.f_half_KS_OLM,results{i}.miss1_KS_OLM,results{i}.miss2_KS_OLM,results{i}.hits_KS_OLM] = calc_f_half ( path1 , path2 , [], [], ...
        [], [], samples_offset,post_process_clusters{i} );
    %% KS to RTS
    path1 = fullfile(fpath,'KS');
    path2 = fullfile(fpath,'RTS');
    [results{i}.f_half_KS_RTS,results{i}.miss1_KS_RTS,results{i}.miss2_KS_RTS,results{i}.hits_KS_RTS] = calc_f_half ( path1 , path2 , [], [], ...
        [], [], samples_offset,post_process_clusters{i} );
    %% OLM to RTS
    path1 = fullfile(fpath,'OLM');
    path2 = fullfile(fpath,'RTS');
    [results{i}.f_half_OLM_RTS,results{i}.miss1_OLM_RTS,results{i}.miss2_OLM_RTS,results{i}.hits_OLM_RTS] = calc_f_half ( path1 , path2 , [], [], ...
        [], [], samples_offset,post_process_clusters{i} );
    
    results{i}.path = fpath;
end
results = cat(1,results{:});
return