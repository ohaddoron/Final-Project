% input:

% fname         full file name 
% nchans        number of channels
% tmplates      n_chanels X tmplate_time_length X N_clusters
% max_offset    maxsimal samples offset between res time stamp to tmplate offset
%path2clu, path2res paths to res and clu files for comperison
% % clusters2remove iralavant clusters in clu file (if sorce is KS then first cluster is junk
% tmplat_amplituds,amps_std  N_clusters elemnts vectors

%  output

% cor_M a N_clusters X N_spikes matrix every cell contains the corolation scror
% per spike per cluster/
% liklihod  N_clusters X N_spikes matrix contin the lliklihood of an amp per spike per cluster


function [cor_M,liklihod] = PCA_analysis2(fname,nchans,template_time_length ...
    ,path2clu, path2res , clusters2remove)
% initialize output
allspikes=[];

% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]
N_PC=2;


% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;

%  load clu res
 [clu,res] = load_clu_res (path2clu, path2res , clusters2remove);
 clusternames=unique(clu);
 N_cluster=length(clusternames);
 N_spikes_tot=length(clu);
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
            (bsize+template_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+template_time_length ] );
    elseif i==nblocks  % in last batch start from batchoffset-tmplate_time_length and read extra tmplate_time_length
        m = memmapfile( fname, 'Format', 'int16', 'Offset', (boff-template_time_length*nchans * nbytes), ...
            'Repeat', (bsize+template_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+template_time_length ] );
    else% in last batch start from batchoffset-tmplate_time_length and read 2 extra tmplate_time_length
        m = memmapfile( fname, 'Format', 'int16', 'Offset', (boff-template_time_length*nchans * nbytes),...
            'Repeat', (bsize+2*template_time_length)*nchans, 'writable', true );
        d = reshape( m.data, [ nchans bsize+2*template_time_length ] );
    end
    spikes_in_batch=sum(and(res>(i-1)*blocksize,res<(i-1)*blocksize+bsize+1));
    tmpres=res(and(res>(i-1)*blocksize,res<(i-1)*blocksize+bsize+1))-(i-1)*blocksize;
    tmpwaveform=zeros(nchans,template_time_length,spikes_in_batch);
    for j=1:spikes_in_batch
        if i==1%in batch spike NO OFFSET
            spike_wavform=double(d(:,((tmpres(j)-template_time_length/2):...
              (tmpres(j)+template_time_length/2-1))));
        else
            try
                % if there are not enough time points to sample
                % for this spike, break and finish. this happens at
                % the last spike in the batch - ON
%                     in non first batch ther is  a tmplate_time_length
%                     offset
                spike_wavform=double(d(:,template_time_length+((tmpres(j)-template_time_length/2):...
                    (tmpres(j)+template_time_length/2-1))));
                spike_wavform=normr(spike_wavform);
            catch
                break
            end
        end
        tmpwaveform(:,:,j)=spike_wavform;
    end
    allspikes=cat(3,allspikes,tmpwaveform);
    clear d m spikes_in_batch tmp_cor_M tmp_amp
%     toc;
end
meanclusterPC=zeros(N_PC*nchans,N_cluster);
sigma=zeros(N_PC*nchans,N_PC*nchans,N_cluster);
sigmainv=zeros(N_PC*nchans,N_PC*nchans,N_cluster);
score=zeros(nchans,N_spikes_tot,N_PC);
for j=1:nchans
    [~,score(j,:,:),~] = pca((squeeze(allspikes(j,:,:)))','NumComponents',N_PC );
    
end
 score=permute(score,[1 3 2]);
for i=1:N_cluster
    spike_idx=clu==clusternames(i);
    spikesincluster(i)=sum(spike_idx);
    tmpscore=score(:,:,spike_idx);
    tmpscore2=reshape(tmpscore ,[nchans*N_PC,spikesincluster(i)]);
    for j=1:nchans
        meanclusterPC(:,i)=squeeze(mean(tmpscore(j,:,:),3))';
        centered_score=tmpscore-repmat(meanclusterPC(:,i)',spikesincluster(i),1);
        sigma(:,:,i)=centered_score'*centered_score/(spikesincluster(i)-1);
        sigmainv(:,:,i)=sigma(:,:,i)^-1;
    end
end
D_squr=cell(N_cluster);
for i=1:N_cluster
    D_squr2{i}=zeros(spikesincluster(i),1);
    D_squr2{i}=diag(score{i}(:,:)*sigmainv(:,:,i)*(score{i}(:,:))');
end

return