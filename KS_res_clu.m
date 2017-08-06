function KS_path = KS_res_clu ( dat_paths , remove_noise )

%% init
nFolders = length( dat_paths );
KS_path = cell(nFolders,1);
%% cycle through folders
for i = 1 : nFolders
    fpath = dat_paths{i};
    [KS_path{i},~,~] = fileparts(fpath);
    KS_path{i} = fullfile(KS_path{i},'KS');
    if ~exist(KS_path{i},'dir')
        mkdir(KS_path{i});
    end
    
    files = dir(fpath);
    idx2clu = ~cellfun(@isempty,strfind({files.name},'.clu.'));
    idx2res = ~cellfun(@isempty,strfind({files.name},'.res.'));
    idx2templates = ~cellfun(@isempty,strfind({files.name},'templates.mat'));
    path2clu = fullfile(fpath,files(idx2clu).name);
    path2res = fullfile(fpath,files(idx2res).name);
    path2templates = fullfile(fpath,files(idx2templates).name);
    
    if remove_noise
        load(path2templates);
        templates_idx = noise_remover(merged_templates);
        [clu,res] = load_clu_res(path2clu,path2res,0);
        idx2remove = ~ismember(clu,templates_idx);
        clu(idx2remove) = [];
        res(idx2remove) = [];
        dlmwrite(fullfile(KS_path{i},'KS.clu.1'),[length(unique(clu)); clu]);
        dlmwrite(fullfile(KS_path{i},'KS.res.1'),res,'precision',100);
        continue
    end
    
    copyfile(path2clu,fullfile(KS_path{i},files(idx2clu).name));
    copyfile(path2clu,fullfile(KS_path{i},files(idx2res).name));
end
        