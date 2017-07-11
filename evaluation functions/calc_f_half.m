function [f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , res1name, res2name, ...
    clu1name, clu2name, samples_offset,varargin )

if length(varargin) >= 1
    post_process_clusters = varargin{1};
end
if length(varargin) >= 2
    remove_noise = varargin{2};
end



% path1 = 'D:\matlab\KiloSort-master\ES Data\Second Half C1_8';
% path2 = 'D:\matlab\KiloSort-master\ES Data\Second Half C1_8';
% path2res1 = fullfile(path1,'es25nov11.013.1.2.3.4.5.6.7.8 split2.res.1');
% path2res2 = fullfile(path2,'es25nov11.013.1.2.3.4.5.6.7.8 split2.res.2');
% path2clu1 = fullfile(path1,'es25nov11.013.1.2.3.4.5.6.7.8 split2.clu.1');
% path2clu2 = fullfile(path2,'es25nov11.013.1.2.3.4.5.6.7.8 split2.clu.2');

% samples_offset=2;
f_half = nan(1,4); 
% first col with all spikes
%% 
files1 = dir(fullfile(path1));
res1name = files1(~cellfun(@isempty,strfind({files1.name},'.res.'))).name;
clu1name = files1(~cellfun(@isempty,strfind({files1.name},'.clu.'))).name;

files2 = dir(path2);
res2name = files2(~cellfun(@isempty,strfind({files2.name},'.res.'))).name;
clu2name = files2(~cellfun(@isempty,strfind({files2.name},'.clu.'))).name;
path2res1 = fullfile(path1,res1name);
path2res2 = fullfile(path2,res2name);
path2clu1 = fullfile(path1,clu1name);
path2clu2 = fullfile(path2,clu2name);

%% calculate hits



[clu1,res1] = load_clu_res (path2clu1,path2res1, 0 ); % load clu1 and res1. remove clusters
... 0 and 1. by convention, these clusters are junk
    
if exist('remove_noise','var')
    if remove_noise
        path2templates = fullfile(path1,'templates.mat');
        load(path2templates);
        templates_idx = noise_remover(merged_templates);
        idx2remove = ~ismember(clu1,templates_idx);
        clu1(idx2remove) = [];
        res1(idx2remove) = [];
    end
end

[clu2,res2] = load_clu_res (path2clu2,path2res2, 0 ); % load clu2 and res2. ...
... remove cluster 0. while merging, any spike originating from an unknown
    ... source 

analysis1 = create_analysis (clu1,res1,clu2,res2,samples_offset) ;
analysis2 = create_analysis (clu2,res2,clu1,res1,samples_offset) ;
hits = create_hits (analysis1,analysis2);
if ~isempty(varargin)
    m = max(post_process_clusters(:));
    num_pad = 1 + m - size(hits,2);
    hits = [hits, zeros(size(hits,1),num_pad)];
end
m = sum(hits,2);
tmp_hits = bsxfun(@rdivide,hits,m);
figure, imagesc(tmp_hits);

%% all spikes
 
[P,R] = precision_recall ( hits );

f_half(1) = 2 * P * R/(P+R);
tmp_hits = hits;
%% remove first row
hits(1,:) = [];
[P,R] = precision_recall ( hits );
f_half(2) = 2 * P * R/(P+R);
hits = tmp_hits;
%% remove first col
hits(:,1) = [];
[P,R] = precision_recall ( hits );
f_half(3) = 2 * P * R/(P+R);
hits = tmp_hits;
 %% remove first row and first col
 hits(:,1) = [];
 hits(1,:) = [];
 [P,R] = precision_recall ( hits );
 f_half(4) = 2 * P * R/(P+R);
 hits = tmp_hits;
%% 
spk1 = sum(hits,2);
spk2 = sum(hits);
miss1 = spk1(1)/sum(spk1); % spikes Eran missed but KS found
miss2 = spk2(1)/sum(spk2); % spikes KS missed but Eran found

