% path2res - path to original res file
% path 2 clu - path to original clu file
% periods - 1x3 cell array. first cell - number of partitions. second cell
% - length  of partition(seconds). third cell - sampling rate
function split_clu_res ( path2res,path2clu,periods )

[clu,res] = load_clu_res(path2clu,path2res,[]);
[~,resname,~] = fileparts(path2res);
[pathstr,cluname,ext] = fileparts(path2clu);
for i = 1 : periods{1}
    min_time = (i-1) * periods{3} * periods{2} + 1;
    max_time = i * periods{3} * periods{2};
    idx2get = res > min_time & res < max_time;
    cur_clu = clu(idx2get);
    cur_clu = [length(unique(cur_clu)); cur_clu];
    cur_res = res(idx2get);
    cur_res = cur_res - min_time + 1;
    [~,cur_res_name] = fileparts(resname);
    [~,cur_clu_name] = fileparts(cluname);
    new_res_name = fullfile(pathstr,[cur_res_name 'p' num2str(i) '.res' ext]);
    new_clu_name = fullfile(pathstr,[cur_clu_name 'p' num2str(i) '.clu' ext]);
    dlmwrite(new_res_name,cur_res,'precision',100);
    dlmwrite(new_clu_name,cur_clu);
end
    
    
    
