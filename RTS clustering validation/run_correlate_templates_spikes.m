fpath = 'D:\MATLAB\Results\m258r1\m258r1.17.18.19.20.21.22.23.24\40 minutes parts 30 minutes overlap';
offset_val = 1;
overlap_step = 10;
max_time = 40;
Fs = 20e3;


files = dir(fpath);
files(1:2) = [];
files(~[files.isdir]) = [];

names = sort(cellfun(@str2num,{files.name}));
RTS_clu = cell(20,1);
RTS_res = cell(20,1);
nFolders = length(names);
for i = 2 : nFolders
    if i > 2 
        fpath0 = fullfile(fpath,sprintf('%d',names(i-1)));
        files = dir(fpath0);
        name = {files.name};
        templates_idx = ~cellfun(@isempty,strfind(name,'templates.mat'));
        load(fullfile(fpath1,files(templates_idx).name));
        templates0 = merged_templates;
    end
    fpath1 = fullfile(fpath,sprintf('%d',names(i-1)));
    fpath2 = fullfile(fpath,sprintf('%d',names(i)));
    
    files = dir(fpath1);
    name = {files.name};
    templates_idx = ~cellfun(@isempty,strfind(name,'templates.mat'));
    load(fullfile(fpath1,files(templates_idx).name));
    templates1 = merged_templates;
    
    if i > 2
        templates2remove = clusters(logical(clusters(:,i-2)) & logical(clusters(:,i-1)),i-2);
        templates0(:,:,templates2remove) = -inf;
    else
        templates0 = ones(size(templates1(:,:,1))) * -inf;
    end
    
        
    

    
%     [clu,res] = correlate_templates_spikes (offset_val,...
%         overlap,max_overlap,templates1, templates2);
%     clu(1) = [];
%     RTS_clu{i} = clu;
%     RTS_res{i} = res;
end
