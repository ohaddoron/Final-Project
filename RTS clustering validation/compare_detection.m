function [ bar_data ] = compare_detection( fpath,offset )

clusters2remove = 0; % clusters # 
template_time_length=82; % used by PCA_analysis to crop the data

% find fname
files = dir(fullfile(fpath,'*.clu*'));
idx = ~cellfun(@isempty,strfind({files.name},'OLM'));
OLM_clu_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'RTS'));
RTS_clu_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'FF_KS'));
FF_KS_clu_path = fullfile(fpath,files(idx).name);

files = dir(fullfile(fpath,'*.res*'));
idx = ~cellfun(@isempty,strfind({files.name},'OLM'));
OLM_res_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'RTS'));
RTS_res_path = fullfile(fpath,files(idx).name);
idx = ~cellfun(@isempty,strfind({files.name},'FF_KS'));
FF_KS_res_path = fullfile(fpath,files(idx).name);


[OLM_clu,OLM_res] = load_clu_res(OLM_clu_path,OLM_res_path,0);
[RTS_clu,RTS_res] = load_clu_res(RTS_clu_path,RTS_res_path,0);
[FF_KS_clu,FF_KS_res] = load_clu_res(FF_KS_clu_path,FF_KS_res_path,0);

idx2remove_OLM = [false; (diff(OLM_res) <= offset)];
idx2remove_RTS = [false; (diff(RTS_res) <= offset)];
OLM_res(idx2remove_OLM) = [];
OLM_clu(idx2remove_OLM) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];
idx2remove_FF_KS = [false; (diff(FF_KS_res) <= offset)];
idx2remove_RTS = [false; (diff(RTS_res) <= offset)];
FF_KS_res(idx2remove_FF_KS) = [];
FF_KS_clu(idx2remove_FF_KS) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];
idx2remove_OLM = [false; (diff(OLM_res) <= offset)];
idx2remove_RTS = [false; (diff(RTS_res) <= offset)];
OLM_res(idx2remove_OLM) = [];
OLM_clu(idx2remove_OLM) = [];
RTS_res(idx2remove_RTS) = [];
RTS_clu(idx2remove_RTS) = [];

Z=zeros(7,1);
Z(1)=length(FF_KS_clu);
Z(3)=length(OLM_clu);
Z(5)=length(RTS_clu);
OLM_FF_KS_idx=false(length(FF_KS_clu),1);
RTS_FF_KS_idx=false(length(FF_KS_clu),1);

Z(2) = 0;
for l = -offset:offset
    Z(2) = Z(2) + sum(ismember(FF_KS_res+l,OLM_res));
    OLM_FF_KS_idx=ismember(FF_KS_res+l,OLM_res)|OLM_FF_KS_idx;
end

Z(6) = 0;
for l = -offset:offset
    Z(6) = Z(6) + sum(ismember(FF_KS_res+l,RTS_res));
    RTS_FF_KS_idx=ismember(FF_KS_res+l,RTS_res)|RTS_FF_KS_idx;
end

Z(4) = 0;
for l = -offset:offset
    Z(4) = Z(4) + sum(ismember(OLM_res+l,RTS_res));
end

Z(7) = sum(OLM_FF_KS_idx&RTS_FF_KS_idx);

% vennX(round(Z./1e4),5/100);
bar_data=[Z(7)/Z(1);(Z(4)-Z(7))/Z(1);(Z(1)-Z(4))/Z(1);(Z(3)-Z(2)-Z(4)+Z(7))/Z(1);(Z(4)-Z(7))/Z(1);(Z(5)-Z(6)-Z(4)+Z(7))/Z(1)];
bar_data=cat(2,bar_data,nan(6,1));
figure;
bar(bar_data','stacked');
legend('KS?OLM?RTS','KS?OLM','KS','OLM\KS','OLM?RTS\KS','RTS\KS','Location','eastoutside');
xlim([.5 1.5]);
end

