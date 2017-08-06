function copy_KS_files_full ( fpaths,path2config1 )%% init

nFolders = length(fpaths);
%% cycle through shanks
for i = 1 : nFolders
    copyfile(fullfile(path2config1,'*.m'),fullfile(fpaths{i}));
end
            