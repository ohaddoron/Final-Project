function [ allspikes ] = read_spikes( fname ,nchans,template_time_length,clu,res,varargin)
%varargin{1} is normalize spiks falg if true noemlaize if false not 
resOffest=1;  %constasnt offset between spike center in .dat file to .res  file values
nbytes=2;
blocksize=1e6;
%% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;
%%  go over blocks and analyze
% if we ever use the entire data set, this will have to be altered to work
% on blocks for real and not as it is currently reading all blocks and
% saving them. Currently, we are working batch-wise and saving the spikes
% in each batch
allspikes=[];
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
            try 
                spike_wavform=double(d(:,((tmpres(j)-template_time_length/2+resOffest):...
                  (tmpres(j)+template_time_length/2-1+resOffest)))); 
            catch 
                continue
            end
            if isempty(varargin) %mormalaize only if varargin{1}==1 or if no varargin
                spike_wavform=spike_wavform/sum(spike_wavform(:).^2);
            elseif varargin{1} == 1
                spike_wavform=spike_wavform/sum(spike_wavform(:).^2);                
            end
            else
                try
                    % if there are not enough time points to sample
                    % for this spike, break and finish. this happens at
                    % the last spike in the batch - ON
%                     in non first batch ther is  a tmplate_time_length
%                     offset
                    spike_wavform=double(d(:,template_time_length+((tmpres(j)-template_time_length/2+resOffest):...
                        (tmpres(j)+template_time_length/2-1+resOffest))));
                    % normalize each tmplate so the norm of a tmplate is 1
                    if or(isempty(varargin),varargin{1}==1)
                        spike_wavform=spike_wavform/sum(spike_wavform(:).^2); %mormalaize only if varargin{1}==1 or if no varargin
                    end 
                catch
                    continue
                end
        end
        tmpwaveform(:,:,j)=spike_wavform;
    end
    allspikes=cat(3,allspikes,tmpwaveform);
    clear d m spikes_in_batch tmp_cor_M tmp_amp tmpwaveform
%     toc;
end
end

