function [clu,res] = run_correlate_templates_spikes(fpath,offset_val,overlap_step,max_time,Fs,clusters)
%% init
max_step = max_time * Fs * 60;
overlap_step = overlap_step * Fs * 60;
clu = [];
res = [];
files = dir(fpath);
files(1:2) = [];
files(~[files.isdir]) = [];
names = sort(cellfun(@str2num,{files.name}));
RTS_clu = cell(20,1);
RTS_res = cell(20,1);
nFolders = length(names);
%% 
for i = 2 : nFolders

    fpath1 = fullfile(fpath,sprintf('%d',names(i-1)));
    fpath2 = fullfile(fpath,sprintf('%d',names(i)));
    nSamples = min((i-1)*overlap_step,max_step);
    samples2use = nSamples - overlap_step;
    [tmp_clu,tmp_res] = correlate_templates_spikes(fpath1,fpath2,offset_val,samples2use);
    new_clu = tmp_clu;
    cur_clu = unique(clusters(:,i-1));
    cur_clu(~logical(cur_clu)) = [];
    for k = 1 : length(cur_clu)
        new_clu(tmp_clu == cur_clu(k)) = find(clusters(:,i-1) == cur_clu(k));
    end
    new_res = tmp_res + (i-1) * overlap_step;
        
    clu = [clu; new_clu];
    res = [res; new_res];
        
    
end
clu = [length(unique(clu)); clu];
dlmwrite(fullfile(fpath,'RTS.clu.3'),clu);
dlmwrite(fullfile(fpath,'RTS.res.3'),res,'precision',100);
return

