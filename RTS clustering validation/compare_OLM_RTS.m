function result = compare_OLM_RTS (fpath,offset,thresh,varargin)
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

% [~,~,ID_OLM] = PCA_analysis(fpath,nchans,template_time_length,...
%     clusters2remove,'KS',offset,[]);
% [~,~,ID_RTS] = PCA_analysis(fpath,nchans,template_time_length,...
%     clusters2remove,'RTS',offset,[]);

%% save to result struct

idx2remove_OLM = [false; (diff(OLM_res) <= offset)];
idx2remove_RTS = [false; (diff(RTS_res) <= offset)];
OLM_res(idx2remove_OLM) = [];
OLM_clu(idx2remove_OLM) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];




idx_OLM = [];
idx_RTS = [];
tmp_RTS_res = RTS_res;
tmp_OLM_res = OLM_res;

for i = - offset : offset
    [C,ia,ib] = intersect(tmp_OLM_res + i,tmp_RTS_res);
    
    match_idx_OLM = ismember(tmp_OLM_res+i,C);
    match_idx_RTS = ismember(tmp_RTS_res,C);
    tmp_OLM_res(match_idx_OLM) = nan;
    tmp_RTS_res(match_idx_RTS) = nan;
    idx_OLM = [idx_OLM; find(match_idx_OLM)];
    idx_RTS = [idx_RTS; find(match_idx_RTS)];
    if length(idx_OLM) ~= length(idx_RTS)
        flag = 1;
    end
%     idx_RTS(ismember(RTS_res,OLM_res + i)) = true;
end
result.FP_detection=1-length(idx_RTS)/length(RTS_clu);
result.TP_detection=length(idx_RTS)/length(OLM_clu);

OLM_clu = OLM_clu(idx_OLM);
RTS_clu = RTS_clu(idx_RTS);

n_clusters_OLM = max(unique(OLM_clu));
nSpikes_OLM = zeros(1,n_clusters_OLM);
for i = 1 : n_clusters_OLM
    nSpikes_OLM(i) = sum(OLM_clu == i);
end

n_clusters_RTS = max(unique(RTS_clu));
nSpikes_RTS = zeros(1,n_clusters_RTS);
for i = 1 : n_clusters_RTS
    nSpikes_RTS(i) = sum(RTS_clu == i);
end

result.TP = nan(n_clusters_OLM,1);
result.FP = nan(n_clusters_OLM,1);
for i = 1 : n_clusters_OLM
    
    tmp_clu_OLM = OLM_clu;
    tmp_clu_OLM(OLM_clu ~= i) = nan;
    
    tmp_clu_RTS = RTS_clu;
    tmp_clu_RTS(RTS_clu ~= i) = nan;
    
    if isempty(tmp_clu_RTS)
        continue
    end
    result.TP(i) = nansum((tmp_clu_OLM - tmp_clu_RTS) == 0) / nSpikes_OLM(i);
    tmp = OLM_clu - tmp_clu_RTS;
    tmp(isnan(tmp)) = [];
    if i <= n_clusters_RTS
        result.FP(i) = nansum(tmp ~= 0) / nSpikes_RTS(i);
    else
        continue
    end
    
end
result.FP(ID < thresh) = nan;
result.hits(ID < thresh) = nan;
result.correlation_matrix = cor_M;
% result.RTS_clu = [length(unique(RTS_clu)); RTS_clu];
result.probabilities = p;
% result.likelihood = liklihod;
result.I_dis=ID;
return


