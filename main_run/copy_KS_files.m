function copy_KS_files ( fpaths, path2config1,path2config2 )

%% init
nFolders = length(fpaths);
%% cycle through shanks
for i = 1 : nFolders
    cur_folders = dir(fpaths{i});
    cur_folders(1:2) = [];
    cur_folders(~[cur_folders.isdir]) = [];
    %% cycle through times
    for k = 1 : length(cur_folders)
        if strcmp(cur_folders(k).name,'1')
            config_path = path2config1;
        else
            config_path = path2config2;
        end
        copyfile(fullfile(config_path,'*.m'),fullfile(fpaths{i},cur_folders(k).name));
    end
end
            