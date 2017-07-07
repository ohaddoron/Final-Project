% input:

% fpath         pathway to the folder holding the res and clu files

% nchans        number of channels

% template_time_length - Length of the templates used. % 82

% clusters2remove irrelevant clusters in clu file (if sorce is KS then
%                 first cluster is junk if KK the the first 2 are junk)

% resOffest      offset between res and spike peak

% output:

% D_sqr         Distance matrix calculated according to the mahal distance

% L_ratio       L_ratio of each cluster
% ID            Isolation distance for each cluster


% merged_templates_idx has been removed


function [D_sqr,L_ratio,ID] = PCA_analysis...
    (fpath,nchans,template_time_length,clusters2remove,clusterMethod,resOffest,merged_templates_idx)
%% initialize 
allspikes=[];
% Use 2 if files are the output of KS and 1 if the files are the output of
% KK.
switch clusterMethod 
    case 'KS'
        files = dir(fullfile(fpath,'*.2'));
    case 'KK'
        files = dir(fullfile(fpath,'*.1'));
end
clu_idx = ~cellfun(@isempty,strfind({files.name},'clu'));
res_idx = ~cellfun(@isempty,strfind({files.name},'res'));
path2clu = fullfile(fpath,files(clu_idx).name);
path2res = fullfile(fpath,files(res_idx).name);


files = dir(fullfile(fpath,'*.dat'));
temp_wh_idx = ~cellfun(@isempty,strfind({files.name},'temp_wh.dat'));
fname = fullfile(fpath,files(temp_wh_idx).name);

%% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]
N_PC=3;


%% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;

%%  load clu res
[clu,res] = load_clu_res (path2clu, path2res , clusters2remove);
merged_templates_idx = repmat((1 : length(unique(clu)))', 1 , 2);
clusternames=merged_templates_idx(:,2);
N_cluster=length(clusternames);
N_spikes_tot=length(clu);
%%  go over blocks and analyze
% if we ever use the entire data set, this will have to be altered to work
% on blocks for real and not as it is currently reading all blocks and
% saving them. Currently, we are working batch-wise and saving the spikes
% in each batch
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
            spike_wavform=double(d(:,((tmpres(j)-template_time_length/2+resOffest):...
              (tmpres(j)+template_time_length/2-1+resOffest)))); 
            spike_wavform=normr(spike_wavform);
            else
                try
                    % if there are not enough time points to sample
                    % for this spike, break and finish. this happens at
                    % the last spike in the batch - ON
%                     in non first batch ther is  a tmplate_time_length
%                     offset
                    spike_wavform=double(d(:,template_time_length+((tmpres(j)-template_time_length/2+resOffest):...
                        (tmpres(j)+template_time_length/2-1+resOffest))));
                    % normalize each row so the norm of a row is 1
                    spike_wavform=normr(spike_wavform); 
                catch
                    break
                end
        end
        tmpwaveform(:,:,j)=spike_wavform;
    end
    allspikes=cat(3,allspikes,tmpwaveform);
    clear d m spikes_in_batch tmp_cor_M tmp_amp tmpwaveform
%     toc;
end

%% Ghost code
% Using the mahal function instead of calculating the mean and coviariance
% matrix of each cluster. Ori claims he will fix it one day
% meanclusterPC=zeros(N_PC*nchans,N_cluster);
% sigma=zeros(N_PC*nchans,N_PC*nchans,N_cluster);
% sigmainv=zeros(N_PC*nchans,N_PC*nchans,N_cluster);

%% Perform PCA on the spikes extracted from the data
score=zeros(nchans,N_spikes_tot,N_PC);
for j=1:nchans
    [~,tmp,~] = pca((squeeze(allspikes(j,:,:)))','NumComponents',N_PC );
    [score(j,:,:)]=tmp;
end
score=permute(score,[1 3 2]); % nchannels X nFeature X nSpikes
score2=reshape(permute(score,[2 1 3]) ,[nchans*N_PC,N_spikes_tot]);
%%  Use only if you wish to use the feature files
% This is currently set so the fet file has to have the same ending as the
% clu and res files (.1)
% try
%     path2fet = strrep(path2clu,'clu','fet');
%     score2=load_fet(path2fet,8,3);
% catch
%     ...
% end
%% Calculate the D_sqr matrix using the mahal function
D_sqr=zeros(N_cluster,N_spikes_tot);
spikesincluster=zeros(N_cluster,1);
for i=1:N_cluster
    spike_idx=clu==clusternames(i);
    spikesincluster(i)=sum(spike_idx);
    X=score2(:,spike_idx)';
    if size(X,2) < size(X,1)
        D_sqr(i,:)=mahal(score2',X)';
    else
        % we think that for some cases, an empty template (or nearly empty)
        % is created. If this is the case, we will ignore this cluster and
        % set the mahal distance as infinity
        D_sqr(i,:) = inf; 
    end
end
%% Ghost code
% Same as above (mahal distance)
% for i=1:N_cluster
%     spike_idx=clu==clusternames(i);
%     spikesincluster(i)=sum(spike_idx);
%     tmpscore=score2(:,spike_idx);
%     meanclusterPC(:,i)=(mean(tmpscore,2));
% %     centered_score=tmpscore-repmat(meanclusterPC(:,i),1,spikesincluster(i));
% %     sigma(:,:,i)=centered_score*centered_score'/(spikesincluster(i)-1);
%     sigma(:,:,i)=cov(tmpscore');
%     sigmainv(:,:,i)=sigma(:,:,i)^(-1);
% end
% D_sqr=zeros(N_cluster,N_spikes_tot);
% % D_sqr2=D_sqr;
% for i=1:N_cluster
% %     D_sqr2(i,:)=diag(score2(:,:)'*sigmainv(:,:,i)*(score2(:,:))); this
% %     line is equivalent to the next but more effitiante
%     D_sqr(i,:)=sum((score2(:,:)'*sigmainv(:,:,i))'.*(score2(:,:)));
% end

%% calculate L ratio according to Shmitzer-Torbert 2005
L_ratio = zeros(N_cluster,1);
for i = 1 : N_cluster
    spike_idx=clu~=clusternames(i); % find spikes not located in the cluster
    L_ratio(i) = (sum(1-chi2cdf(D_sqr(i,spike_idx),size(score2,1))))/(spikesincluster(i));
end

%% Calculate ID according to Shmitzer-Torbert 2005
ID = zeros(N_cluster,1);
for i = 1 : N_cluster
    tmp_D_sqr=D_sqr(i,:);
    spike_idx=clu==clusternames(i); 
    tmp_D_sqr(spike_idx)=nan;
    tmp_D_sqr=sort(tmp_D_sqr,'ascend');
    if spikesincluster(i) > 0
        ID(i)=tmp_D_sqr(spikesincluster(i));
    else
        % if one of the clusters is empty, spikesincluster will be 0. in
        % this case, the isolation distance will be 0
        ID(i) = 0;
    end
    
    if isnan(ID(i))
        % if the current cluster contains more than half the amount of
        % spikes found, this value will be nan. if this is the case, the
        % isolation distance is the spike located furthest away from the
        % center
        ID(i) = nanmax(tmp_D_sqr);
    end
end

return