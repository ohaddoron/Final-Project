function run_kilosort (path2results)

%% run kilosort
if 1 > 2
    waitfor(helpdlg('Select Kilosort folder'));
    path2kilosort = uigetdir;
else
    path2kilosort = 'D:\matlab\KiloSort-master';
end
addpath(genpath(path2kilosort));

num_of_files = length(path2results);

for i = 1 : num_of_files
    files = dir(fullfile(path2results{i}));
    names = {files.name};
    idx2dat = find(~cellfun(@isempty,strfind(names,'dat')));
    idx2master = find(~cellfun(@isempty,strfind(names,'master')));
    path2dat = fullfile(path2results{i},files(idx2dat(1)).name);
    run(fullfile(path2results{i},files(idx2master).name));
end