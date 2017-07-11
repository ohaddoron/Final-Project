function result = test_score (fpath,thresh)
%% load data and get paths
% find fname
files = dir(fullfile(fpath,'*.dat'));
idx = find(~cellfun(@isempty,strfind({files.name},'temp_wh.dat')));
fname = fullfile(fpath,files(idx).name);
% find clu and res path
files = dir(fullfile(fpath,'*.2'));
clu_idx = ~cellfun(@isempty,strfind({files.name},'clu'));
res_idx = ~cellfun(@isempty,strfind({files.name},'res'));
path2clu = fullfile(fpath,files(clu_idx).name);
path2res = fullfile(fpath,files(res_idx).name);
% load templates
load(fullfile(fpath,'templates.mat'));
% load(fullfile(fpath,'amplitudes.mat'));
clusterMethod = 'KS'; % KK or KS


%% run correlation
nchans = 8;
% thresh = 20; % threshold used for as a minimal isolation distance
tmplates = merged_templates;
resOffset = 1; % For some reason, there is an offset between the time in
               % which the rest claims the peak occured. We found this
               % delay to be 1 sample
clusters2remove = 0; % clusters # 
template_time_length=82; % used by PCA_analysis to crop the data
[cor_M,~,amps] = correlation_meas(fname,nchans,tmplates...
    ,resOffset,path2clu, path2res , clusters2remove,false);
[D_sqr,L_ratio,ID] = PCA_analysis...
    (fpath,nchans,template_time_length,clusters2remove,clusterMethod,resOffset,merged_templates_idx);

%% test results
[clu,~] = load_clu_res (path2clu, path2res , clusters2remove);
[X,I] = nanmax(cor_M);
RTS_clu = I';
RTS_clu(sum(~isnan(cor_M))==0) = nan;
% calc significance of max
n_clusters = length(unique(clu(2:end)));
mu = nanmean(cor_M);
sigma = nanstd(cor_M);

p = 1/2* (1+ erf((X-mu)./(sigma*sqrt(2))));
%% save to result struct


% for i = 1 : n_clusters
%     result.hits(i) = nansum(clu(clu==merged_templates_idx(i,2)) - ...
%         RTS_clu(clu==merged_templates_idx(i,2)) == 0)/...
%         length(clu(clu==merged_templates_idx(i,2))) * 100;
%     result.FP(i) = nansum(clu(RTS_clu==merged_templates_idx(i,2)) - ...
%         RTS_clu(RTS_clu==merged_templates_idx(i,2)) ~= 0)/...
%         length(RTS_clu(RTS_clu==merged_templates_idx(i,2))) * 100;
% end
result.FP(ID < thresh) = nan;
result.hits(ID < thresh) = nan;
result.correlation_matrix = cor_M;
% result.RTS_clu = [length(unique(RTS_clu)); RTS_clu];
result.probabilities = p;
% result.likelihood = liklihod;
result.I_dis=ID;
return


