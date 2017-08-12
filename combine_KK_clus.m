%% init
path = 'D:\MATLAB\testset\m649r1';
outpath = 'D:\MATLAB\Results\test\m649r1\m649r1\25 - 32\KK';
folders = dir(path);
folders(1:2) = [];
folders(~[folders.isdir]) = [];
nFolders = length(folders);
nchans = 56;
nbytes = 2;
nsamples = 0;
clu = cell(nFolders,1);
res = cell(nFolders,1);
%% main
for i = 1 : nFolders
    cur_path = fullfile(path,folders(i).name);
    files = dir(cur_path);
    idx = ~cellfun(@isempty,strfind({files.name},'clu.4'));
    path2clu = fullfile(cur_path,files(idx).name);
    idx = ~cellfun(@isempty,strfind({files.name},'res.4'));
    path2res = fullfile(cur_path,files(idx).name);
    
    idx = ~cellfun(@isempty,strfind({files.name},'.dat'));
    path2dat = fullfile(cur_path,files(idx).name);
    file = dir(path2dat);
    
    
    [clu{i},res{i}] = load_clu_res(path2clu,path2res,0);
    res{i} = res{i} + nsamples;
        
    nsamples = nsamples + file.bytes / nbytes / nchans;
    
    
end
clu = cat(1,clu{:});
res = cat(1,res{:});
if ~exist(outpath,'dir'), mkdir(outpath), end;        
dlmwrite(fullfile(outpath,'KK.clu.1'),[length(unique(clu)) ; clu]);
dlmwrite(fullfile(outpath,'KK.res.1'),res,'precision',100);      
