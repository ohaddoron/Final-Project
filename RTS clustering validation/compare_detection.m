function [ detection_resulrs ] = compare_detection(KS_path,OLM_path,RTS_path ,offset )
%fpath - path to all res&clu files
%  detection_resulrs: 7 element arreay
% 'KS&OLM&RTS','KS&OLM&not_RTS','KS&RTS&not_OLM','KS&not_RTS&not_OLM'
%,'only OLM' '(OLM | RTS) - KS','onlyRTS'

clusters2remove = 0; % clusters # 
template_time_length=82; % used by PCA_analysis to crop the data

% find fname
KS_files = dir(KS_path);
KS_clu_idx = ~cellfun(@isempty,strfind({KS_files.name},'clu'));
KS_res_idx = ~cellfun(@isempty,strfind({KS_files.name},'res'));
FF_KS_clu_path = fullfile(KS_path,KS_files(KS_clu_idx).name);
FF_KS_res_path = fullfile(KS_path,KS_files(KS_res_idx).name);

OLM_files = dir(OLM_path);
OLM_clu_idx = ~cellfun(@isempty,strfind({OLM_files.name},'clu'));
OLM_res_idx = ~cellfun(@isempty,strfind({OLM_files.name},'res'));
OLM_clu_path = fullfile(OLM_path,OLM_files(OLM_clu_idx).name);
OLM_res_path = fullfile(OLM_path,OLM_files(OLM_res_idx).name);

RTS_files = dir(RTS_path);
RTS_clu_idx = ~cellfun(@isempty,strfind({RTS_files.name},'clu'));
RTS_res_idx = ~cellfun(@isempty,strfind({RTS_files.name},'res'));
RTS_clu_path = fullfile(RTS_path,RTS_files(RTS_clu_idx).name);
RTS_res_path = fullfile(RTS_path,RTS_files(RTS_res_idx).name);





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
%bar_data
% 'KS&OLM&RTS','KS&OLM&not_RTS','KS&RTS&not_OLM','KS&not_RTS&not_OLM'
%,'only OLM' '(OLM | RTS) - KS','onlyRTS'

detection_resulrs=[Z(7)/Z(1);(Z(2)-Z(7))/Z(1);(Z(6)-Z(7))/Z(1);...
    (Z(1)-Z(2)-Z(6)+Z(7))/Z(1);(Z(3)-Z(2)-Z(4)+Z(7))/Z(1);...
    (Z(4)-Z(7))/Z(1);(Z(5)-Z(6)-Z(4)+Z(7))/Z(1)];
% detection_resulrs=cat(2,detection_resulrs,nan(7,1));
% figure;
% bar(detection_resulrs','stacked');
% legend('KS \wedge OLM \wedge RTS','KS \wedge OLM','KS \wedge RTS','KS','only OLM',...
%     '(OLM \vee RTS) - KS','onlyRTS','Location','eastoutside');
% xlim([.5 1.5]);
end

