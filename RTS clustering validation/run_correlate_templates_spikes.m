fpath = 'D:\MATLAB\Results\m258r1\m258r1.17.18.19.20.21.22.23.24\40 minutes parts 30 minutes overlap';
offset_val = 1;

files = dir(fpath);
files(1:2) = [];
files(~[files.isdir]) = [];

names = sort(cellfun(@str2num,{files.name}));
RTS_clu = cell(20,1);
RTS_res = cell(20,1);
nFolders = length(names);
for i = 2 : nFolders
    fpath1 = fullfile(fpath,sprintf('%d',names(i-1)));
    fpath2 = fullfile(fpath,sprintf('%d',names(i)));
    [clu,res] = correlate_templates_spikes ( fpath1,fpath2,offset_val );
    clu(1) = [];
    RTS_clu{i} = clu;
    RTS_res{i} = res;
end
