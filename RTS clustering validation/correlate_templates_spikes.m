% fpath1 - path to folder with previous frame
% fpath2 - path to folder with current frame
% offset_val - scalar indicating offset range to use (in samples)
% samples2use - indicating the number of samples to use from each res i.e.
% the overlap time
% template_time_length - number of samples used in each template
% templates_idx - templates to be removed

% note - we attempted to classify spikes to noisy templates and then
% removing spikes correlated to those templates. This attempt failed. We
% believe that the noisy templates represent spikes with very low
% amplitudes. As long as the detection is performed using a global
% threshold, these spikes will not be found by the RTS and thus we don't
% have to deal with them
function [RTS_clu,res,corr] = correlate_templates_spikes ( fpath1,fpath2,offset_val,samples2use,template_time_length,templates_idx)
%% init
offsets = - offset_val: offset_val;
nOffsets = length(offsets);
fname = fullfile(fpath1,'templates.mat');
load(fname);
templates = merged_templates;
templates(:,:,~ismember(1:size(templates,3),templates_idx)) = -inf;
[nchans,nTP,nTemplates] = size(templates);
files = dir(fpath2);
names = {files.name};
raw_data_idx = ~cellfun(@isempty,strfind(names,'temp_wh.dat'));
%% spike detection
fname = fullfile(fpath2,files(raw_data_idx).name);
res = spikeDetection ( fname, nchans,template_time_length );
res = res(res > samples2use);
if isempty(res)
    flag = 1;
end
spikes  = read_spikes( fname ,nchans,nTP,[],res,0 );
nSpikes = size(spikes,3);
corr = zeros(nTemplates,nSpikes,nOffsets);
count = 1;
% samples = min(i * overlap_step, max_step);
% idx = res > samples - overlap_step;
% res(~idx) = [];
%% removal of well correlated spikes
% norm_factor = sum(sum(spikes.^2));
% norm_spikes = bsxfun(@rdivide,spikes,norm_factor);
% spikes_idx = noise_remover(norm_spikes);
%% main
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

%% remove spikes with correlation to noisy templates
% idx2remove = ~ismember(RTS_clu,templates_idx);
% res(idx2remove) = [];
% RTS_clu(idx2remove) = [];

RTS_clu = RTS_clu';
% nClusters = length(unique(RTS_clu));
% RTS_clu = [RTS_clu; nClusters];
