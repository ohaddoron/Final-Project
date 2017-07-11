function result = compare_OLM_RTS (fpath,offset)
%% load data and get paths
% find fname
files = dir(fullfile(fpath,'*.clu*'));
idx = ~cellfun(@isempty,strfind({files.name},'OLM'));
OLM_clu_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'RTS'));
RTS_clu_path = fullfile(fpath,files(idx).name);

files = dir(fullfile(fpath,'*.res*'));
idx = ~cellfun(@isempty,strfind({files.name},'OLM'));
OLM_res_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'RTS'));
RTS_res_path = fullfile(fpath,files(idx).name);


[OLM_clu,OLM_res] = load_clu_res(OLM_clu_path,OLM_res_path,0);
[RTS_clu,RTS_res] = load_clu_res(RTS_clu_path,RTS_res_path,0);


%% run correlation
nchans = 8;
% thresh = 20; % threshold used for as a minimal isolation distance
clusters2remove = 0; % clusters # 
template_time_length=82; % used by PCA_analysis to crop the data

[~,~,ID_OLM] = PCA_analysis(fpath,nchans,template_time_length,...
    clusters2remove,'KS',offset,[]);
[~,~,ID_RTS] = PCA_analysis(fpath,nchans,template_time_length,...
    clusters2remove,'RTS',offset,[]);

%% save to result struct


n_clusters_OLM = max(unique(OLM_clu));
nSpikes_OLM = zeros(1,n_clusters_OLM);
for i = 1 : n_clusters_OLM
    nSpikes_OLM(i) = sum(OLM_clu == i);
end



idx2remove_OLM = [false; (diff(OLM_res) == 0)];
idx2remove_RTS = [false; (diff(RTS_res) == 0)];
OLM_res(idx2remove_OLM) = [];
OLM_clu(idx2remove_OLM) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];

idx_OLM = [];
idx_RTS = [];

for i = - offset : offset
    [~,ia,ib] = intersect(OLM_res,RTS_res);

    idx_OLM = unique([idx_OLM; ia]);
    idx_RTS = unique([idx_RTS;ib]);
    if length(idx_OLM) ~= length(idx_RTS)
        flag = 1;
    end
%     idx_RTS(ismember(RTS_res,OLM_res + i)) = true;
end

OLM_clu = OLM_clu(idx_OLM);
RTS_clu = RTS_clu(idx_RTS);

result.TP = nan(n_clusters_OLM,1);

for i = 1 : n_clusters_OLM
    
    tmp_clu_OLM = OLM_clu;
    tmp_clu_OLM(OLM_clu ~= i) = nan;
    
    tmp_clu_RTS = RTS_clu;
    tmp_clu_RTS(RTS_clu ~= i) = nan;
    
    if isempty(tmp_clu_RTS)
        continue
    end
    result.TP(i) = nansum((tmp_clu_OLM - tmp_clu_RTS) == 0) / nSpikes_OLM(i);
    result.FP(i) = nansum((tmp_clu_OLM - tmp_clu_RTS) ~= 0) / nSpikes_OLM(i);
    
end
result.FP(ID < thresh) = nan;
result.hits(ID < thresh) = nan;
result.correlation_matrix = cor_M;
% result.RTS_clu = [length(unique(RTS_clu)); RTS_clu];
result.probabilities = p;
% result.likelihood = liklihod;
result.I_dis=ID;
return


