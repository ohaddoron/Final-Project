function result = compare_OLM_RTS (fpath,offset,thresh,post_process_clusters,varargin)
%% load data and get paths
%% costats
Fs=20e3;
overlap_step=10*60*Fs;
N_clusters  = size (post_process_clusters,1);
nchans = 8;
% thresh = 20; % threshold used for as a minimal isolation distance
clusters2remove = 0; % clusters # 
template_time_length=82; % used by PCA_analysis to crop the data

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

[~,~,ID_OLM] = PCA_analysis(fpath,nchans,template_time_length,...
    clusters2remove,'OLM',offset,[]);
[~,~,ID_RTS] = PCA_analysis(fpath,nchans,template_time_length,...
    clusters2remove,'RTS',offset,[]);

%% save to result struct
%% remove spikes with leess than offset diffrance from analysis 
idx2remove_OLM = [false; (diff(OLM_res) <= offset)];
idx2remove_RTS = [false; (diff(RTS_res) <= offset)];
OLM_res(idx2remove_OLM) = [];
OLM_clu(idx2remove_OLM) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];


%% match spike times and clc FT&TP for detection
idx_OLM = false(length (OLM_res),1);
idx_RTS = false(length (RTS_res),1);
tmp_RTS_res = RTS_res;
tmp_OLM_res = OLM_res;

for i = - offset : offset
    [C,~,~] = intersect(tmp_OLM_res + i,tmp_RTS_res);
    match_idx_OLM = ismember(tmp_OLM_res+i,C);
    match_idx_RTS = ismember(tmp_RTS_res,C);
    tmp_OLM_res(match_idx_OLM) = nan;
    tmp_RTS_res(match_idx_RTS) = nan;
    idx_OLM = or(idx_OLM,match_idx_OLM);
    idx_RTS = or(idx_RTS,match_idx_RTS);
%     if length(idx_OLM) ~= length(idx_RTS)
%         flag = 1;
%     end
%     idx_RTS(ismember(RTS_res,OLM_res + i)) = true;
end
%clc error rates
idx_inherent_E_first_frame=(~idx_OLM) &   (OLM_res<overlap_step);
result.FNR_inherent_first_frame=sum(idx_inherent_E_first_frame)/length(OLM_clu);
result.precision_detection=1-sum(idx_RTS)/length(RTS_clu);
result.sensitivity_detection=sum(idx_RTS)/(length(OLM_clu)-sum(idx_inherent_E_first_frame));

%remove spikes
OLM_clu = OLM_clu(idx_OLM);
OLM_res=OLM_res(idx_OLM);
RTS_clu = RTS_clu(idx_RTS);
RTS_res = RTS_res(idx_RTS);
%compare classification
result.N_spiks_before_inherent=length(RTS_clu);
[ result.sensitivity_calssification,result.precision_calssification ] =...
    compare_clus( OLM_clu ,RTS_clu,N_clusters);

%% compear only possible spikes for RTS
[ life_time ] = clc_life_time( post_process_clusters );
% convert to sampls 
life_time=life_time*overlap_step;
%find inherent spikes
early_spikes = false(length (RTS_res),1);
late_spikes = false(length (RTS_res),1);
for i=1:N_clusters
    tmp_idx=(OLM_res<life_time(i,1))&(OLM_clu==i);
    early_spikes=(tmp_idx|early_spikes);
    tmp_idx=(OLM_res>life_time(i,2))&(RTS_clu==i);
    late_spikes=(tmp_idx|late_spikes);
end
%clc error rates
result.inherent_undetectionble=sum(early_spikes)/length(RTS_clu);
result.inherent_false_calssification=sum(late_spikes)/length(RTS_clu);
%remove spikes
OLM_clu = OLM_clu((~early_spikes)&(~late_spikes));
OLM_res=OLM_res((~early_spikes)&(~late_spikes));
RTS_clu = RTS_clu((~early_spikes)&(~late_spikes));
RTS_res = RTS_res((~early_spikes)&(~late_spikes));

%compare classification
result.N_spiks_after_inherent=length(RTS_clu);
[ result.sensitivity_calssification_rmoved_inherent,...
    result.precision_calssification_rmoved_inherent ] =...
    compare_clus( OLM_clu ,RTS_clu,N_clusters);

% result.I_dis=ID_OLM;


return


