 function [clu,res] = load_clu_res (path2clu, path2res , clusters2remove)


clu=load(path2clu);
clu=clu(2:end); %remove first num on clu file and numer from 1
res=load(path2res);

for i = 1 : length(clusters2remove)
    idx2remove = clu==clusters2remove(i);
    res(idx2remove) = [];
    clu(idx2remove) = [];
end
% clu = 1 + clu;



