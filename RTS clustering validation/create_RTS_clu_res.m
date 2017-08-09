function [clu,res] = create_RTS_clu_res(fpath,offset_val,overlap_step,max_time,Fs,clusters,template_time_length,varargin)
%% init
if length(varargin) >= 1
    thresh = varargin{1};
end
if length(varargin) >= 2
    outpath = varargin{2};
end
if isempty(varargin)
    thresh = 1000;
    outpath = fpath;
end
max_step = max_time * Fs * 60;
overlap_step = overlap_step * Fs * 60;
clu = [];
res = [];
files = dir(fpath);
files(1:2) = [];
files(~[files.isdir]) = [];
i = 1;
while i <= length(files)
    if ~isstrprop(files(i).name,'digit')
        files(i) = [];
    else 
        i = i + 1;
    end
end
    
names = sort(cellfun(@str2num,{files.name}));
RTS_clu = cell(20,1);
RTS_res = cell(20,1);
nFolders = length(names);
clusters(sum(clusters,2)==0,:) = [];
count = 1;
%% 
for i = 2 : nFolders

    fpath1 = fullfile(fpath,sprintf('%d',names(i-1)));
    fpath2 = fullfile(fpath,sprintf('%d',names(i)));
    nSamples = min(i*overlap_step,max_step);
    samples2use = nSamples - overlap_step;
    
    cur_clu = unique(clusters(:,i-1));
    cur_clu(~logical(cur_clu)) = [];
    [tmp_clu,tmp_res] = correlate_templates_spikes(fpath1,fpath2,offset_val,samples2use,template_time_length,cur_clu);
    new_clu = tmp_clu;
    
    for k = 1 : length(cur_clu)
        new_clu(tmp_clu == cur_clu(k)) = find(clusters(:,i-1) == cur_clu(k));
    end
    
    if i > max_step / overlap_step
        new_res = tmp_res + count * overlap_step;
        count = count + 1;
    else
        new_res = tmp_res;    
    end
        
    clu = [clu; new_clu];
    res = [res; new_res];
        
    
end
idx2remove = [false; diff(res) < 0];
while sum(idx2remove) > 0
    res(idx2remove) = [];
    clu(idx2remove) = [];
    idx2remove = [false; diff(res) < 0];
end
clu = [length(unique(clu)); clu];
dlmwrite(fullfile(outpath,'RTS.clu.3'),clu);
dlmwrite(fullfile(outpath,'RTS.res.3'),res,'precision',100);
return

