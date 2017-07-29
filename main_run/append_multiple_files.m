function append_multiple_files (path,fpath,name,nchans)

%% init
files = dir(path);
files(1:2) = [];
files(~[files.isdir]) = [];
nFiles = length(files);
%% cycle through folders and append
for i = 1 : nFiles
    dat_file = dir(fullfile(path,files(i).name,'*.dat'));
    fname = fullfile(path,files(i).name,dat_file.name);
    if i == 1 
        copyfile(fullfile(path,files(i).name,dat_file.name),fullfile(fpath,name));
        fid = fopen(fullfile(fpath,name),'a');
        continue;
    end
    [rc,msg] = append_files(fname,nchans,fid);
end
fclose(fid);