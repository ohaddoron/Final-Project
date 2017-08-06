function dat_paths = move_dat_files ( fpaths )

%% init
nFolders = length(fpaths);
dat_paths = cell(nFolders,1); 
%% cycle through shanks and run KS
for i = 1 : nFolders
    files = dir(fullfile(fpaths{i},'*.dat'));
    dat_paths{i} = fullfile(fpaths{i},'Full');
    if ~exist(dat_paths{i},'dir')
        mkdir(dat_paths{i});
    end
    movefile(fullfile(fpaths{i},files.name),fullfile(dat_paths{i},files.name));
end
return
    


