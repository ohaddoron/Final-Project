<<<<<<< HEAD
function [RTS_clu,res,corr] = correlate_templates_spikes ( offset_val,...
    overlap, max_sample,templates1,varargin )


%% init
if ~isempty(varargin)
    templates2 = varargin{1};
end
offsets = - offset_val: offset_val;
nOffsets = length(offsets);


templates = merged_templates;
templates_idx = noise_remover(templates);
templates(:,:,~ismember(1:size(templates,3),templates_idx)) = -inf;

[nchans,nTP,nTemplates] = size(templates);

files = dir(fpath2);
names = {files.name};
raw_data_idx = ~cellfun(@isempty,strfind(names,'temp_wh.dat'));

%% spike detection
fname = fullfile(fpath2,files(raw_data_idx).name);
res = spikeDetection ( fname, nchans );
% samples = min(i * overlap_step, max_step);
% idx = res > samples - overlap_step;
% res(~idx) = [];
spikes  = read_spikes( fname ,nchans,nTP,[],res,0 );

nSpikes = size(spikes,3);
corr = zeros(nTemplates,nSpikes,nOffsets);
count = 1;
for off = offsets
%% match spikes using cross correlation
    for t = 1 : nTemplates
        cur_template = templates(:,:,t);
        switch sign(off)
            case -1
                cur_template = [zeros(nchans,abs(off)), cur_template(:,1:end + off)];
            case 1 
                cur_template = [cur_template(:,off + 1:end), zeros(nchans,abs(off))];
        end
                
        corr(t,:,count) = squeeze(sum(sum(bsxfun(@times,cur_template,spikes))))/nchans;
    end
    count = count + 1;
end
corr = max(corr,[],3);
[~,RTS_clu] = max(corr);
RTS_clu = RTS_clu';
nClusters = length(unique(RTS_clu));
RTS_clu = [RTS_clu; nClusters];

dlmwrite(fullfile(fpath2,'RTS.clu.3'),RTS_clu);
dlmwrite(fullfile(fpath2,'RTS.res.3'),res,'precision',100);

=======
function [RTS_clu,res,corr] = correlate_templates_spikes ( fpath1,fpath2,offset_val )


%% init
offsets = - offset_val: offset_val;
nOffsets = length(offsets);

files = dir(fpath1);
names = {files.name};
templates_idx = ~cellfun(@isempty,strfind(names,'templates.mat'));
load(fullfile(fpath1,files(templates_idx).name));

templates = merged_templates;
templates_idx = noise_remover(templates);
templates(:,:,~ismember(1:size(templates,3),templates_idx)) = -inf;

[nchans,nTP,nTemplates] = size(templates);

files = dir(fpath2);
names = {files.name};
raw_data_idx = ~cellfun(@isempty,strfind(names,'temp_wh.dat'));

%% spike detection
fname = fullfile(fpath2,files(raw_data_idx).name);
res = spikeDetection ( fname, nchans );
spikes  = read_spikes( fname ,nchans,nTP,[],res,0 );

nSpikes = size(spikes,3);

corr = zeros(nTemplates,nSpikes,nOffsets);
count = 1;
for off = offsets
%% match spikes using cross correlation
    for t = 1 : nTemplates
        cur_template = templates(:,:,t);
        switch sign(off)
            case -1
                cur_template = [zeros(nchans,abs(off)), cur_template(:,1:end + off)];
            case 1 
                cur_template = [cur_template(:,off + 1:end), zeros(nchans,abs(off))];
        end
                
        corr(t,:,count) = squeeze(sum(sum(bsxfun(@times,cur_template,spikes))))/nchans;
    end
    count = count + 1;
end
corr = max(corr,[],3);
[~,RTS_clu] = max(corr);
RTS_clu = RTS_clu';
nClusters = length(unique(RTS_clu));
RTS_clu = [RTS_clu; nClusters];

dlmwrite(fullfile(fpath2,'RTS.clu.3'),RTS_clu);
dlmwrite(fullfile(fpath2,'RTS.res.3'),res,'precision',100);

>>>>>>> e57f3c143d1b023413cfbf2a613f9a62b46f359a
return 