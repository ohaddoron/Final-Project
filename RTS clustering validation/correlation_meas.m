% input:

% fname         full file name 
% nchans        number of channels
% tmplates      n_chanels X tmplate_time_length X N_clusters
% max_offset    maximal samples offset between res time stamp to tmplate offset
%path2clu, path2res paths to res and clu files for comperison
% % clusters2remove iralavant clusters in clu file (if sorce is KS then first cluster is junk
% tmplat_amplituds,amps_std  N_clusters elemnts vectors
% flag          used to set if the correlation should be performed only for
%               channels above the threshold (true) or for all channels
%               (false)
%  output

% cor_M a N_clusters X N_spikes matrix every cell contains the corolation scror
% per spike per cluster/
% liklihod  N_clusters X N_spikes matrix contin the lliklihood of an amp per spike per cluster


function [cor_M,liklihod,amps] = correlation_meas(fname,nchans,tmplates...
    ,max_offset,path2clu, path2res , clusters2remove,flag)
% initialize output

cor_M=[];%size will be N_clusters X N spikes
liklihod=[];
offset_values=max_offset;%changed to only one offset ON

% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]
[ ~ , tmplate_time_length , N_clusters]=size(tmplates);


% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;

%  load clu res
[clu,res] = load_clu_res (path2clu, path2res , clusters2remove);

 
% raw_amps = cell(N_clusters,1);
% clu_idx = merged_templates_idx;

nSpikes = length(clu);
spikes = zeros(nchans,tmplate_time_length,nSpikes);

nClusters = max(unique(clu));
raw_amps = cell(nClusters,1);

% tmplat_amplituds = cellfun(@mean,raw_amps);
% amps_std = cellfun(@std,raw_amps);
 
 
%  go over blocks and analize
for i = 1 : nblocks
%     tic;
    %load dat
    boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
    bsize = ( diff( blocks( i, : ) ) + 1 );
%    to analize sipkes at the ends of a batch read an extra
%    tmplate_time_length at evary batch 
    if i==1 % in first batch start from 0 and read extra tmplate_time_length
        m = memmapfile( fname, 'Format', 'int16', 'Offset', 0, 'Repeat',...
            (bsize+tmplate_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+tmplate_time_length ] );
    elseif i==nblocks  % in last batch start from batchoffset-tmplate_time_length and read extra tmplate_time_length
        m = memmapfile( fname, 'Format', 'int16', 'Offset', (boff-tmplate_time_length*nchans * nbytes), ...
            'Repeat', (bsize+tmplate_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+tmplate_time_length ] );
    else% in last batch start from batchoffset-tmplate_time_length and read 2 extra tmplate_time_length
        m = memmapfile( fname, 'Format', 'int16', 'Offset', (boff-tmplate_time_length*nchans * nbytes),...
            'Repeat', (bsize+2*tmplate_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+2*tmplate_time_length ] );
    end
    
    spikes_in_batch=sum(and(res>(i-1)*blocksize,res<(i-1)*blocksize+bsize+1));
    idx = and(res>(i-1)*blocksize,res<(i-1)*blocksize+bsize+1);
    tmpres = res(idx)-(i-1)*blocksize;
    tmpclu = clu(idx);
    tmp_cor_M=zeros(N_clusters,spikes_in_batch,2*max_offset+1);
    tmp_amp=zeros(spikes_in_batch,2*max_offset+1);
    for j=1:spikes_in_batch
        for l=1 % no offset ON and OD
            if i==1%in batch spike NO OFFSET
                spike_wavform=double(d(:,((tmpres(j)-tmplate_time_length/2+offset_values(l)):...
                  (tmpres(j)+tmplate_time_length/2-1+offset_values(l)))));
                raw_amps{tmpclu(j)}(end+1) = sqrt(sum(spike_wavform(:).^2));

            else
                try
                    % if there are not enough time points to sample
                    % for this spike, break and finish. this happens at
                    % the last spike in the batch - ON
%                     in non first batch ther is  a tmplate_time_length
%                     offset
                    spike_wavform=double(d(:,tmplate_time_length+((tmpres(j)-tmplate_time_length/2+offset_values(l)):...
                        (tmpres(j)+tmplate_time_length/2-1+offset_values(l)))));
                    raw_amps{tmpclu(j)}(end+1) = sqrt(sum(spike_wavform(:).^2));
                catch
                    break
                end
            end
            spikes(:,:,end+1) = spike_wavform;
%             tmp_amp(j,l)=norm(spike_wavform,2);
            spike_wavform=spike_wavform/tmp_amp(j,l);

            intensity = squeeze(sum(tmplates.^2,2));
            if flag
                intensity_SD = std(intensity);
                intensity_mean = mean(intensity);
                thresh = intensity_mean + 0 * intensity_SD;
                
                for k = 1 : size(tmp_cor_M,1)
                    idx = intensity(:,k) > thresh (k);
                    mask = zeros(size(tmplates(:,:,k)));
                    mask(idx,:) = 1;
                    masked_template = tmplates(:,:,k).*mask;
                    masked_template = masked_template / sqrt(sum(masked_template(:).^2));
                    tmp_cor_M(k,j,l) = sum(sum(masked_template.*...
                        spike_wavform))/sum(sum(mask,2)>0);
                end
            else
                spike_wavform=repmat(spike_wavform,1,1,N_clusters);   
                tmp_cor_M(:,j,l)=sum(sum(tmplates(:,:,:).*spike_wavform(:,:,:)))/nchans;
            end
        end
    end
    tmp_cor_M=max(tmp_cor_M,[],3);%take max offset
    cor_M=[cor_M tmp_cor_M];
%     tmp_amp=max(tmp_amp,[],2);
%     tmpliklihod=zeros(N_clusters,spikes_in_batch);
%     for k=1:N_clusters
%         tmpliklihod(k,:)=normcdf(tmp_amp,tmplat_amplituds(k),amps_std(k));
%     end
%     liklihod=[liklihod tmpliklihod];
    clear d m spikes_in_batch tmp_cor_M tmp_amp
%     toc;
end
amps.mu = cellfun(@mean,raw_amps);
amps.sigma = cellfun(@std,raw_amps);

% cor_M(liklihod < significance_thresh) = nan; % setting any correlation value w/ prob less than 
                                             % significance_thresh to nan (ignoring it)
return