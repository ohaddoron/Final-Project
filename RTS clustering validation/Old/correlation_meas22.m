% get channels        from dat file
%
% [ rc, msg ] = getchannels( fname, nchans, chans )
% 
% fname         full file name 
% nchans        number of channels
% gchans        channels to get
% tmplates      n_chanels X tmplate_time_length X N_clusters
% max_offset    maxsimal samples offset between res time stamp to tmplate offset
%
% does
% writes a new file without the chans
%
% see also      removedcoffset, reorderchannels


function [rc,msg,cor_M,liklihod] = correlation_meas22(fname,nchans,tmplates...
    ,max_offset,path2clu, path2res , clusters2remove,tmplat_amplituds,amps_std)
% initialize output
rc = 0;
msg = '';
cor_M=[];%size will be N_clusters X N spikes
liklihod=[];
offset_values=-1*max_offset:max_offset;

% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]
[ ~ , tmplate_time_length , N_clusters]=size(tmplates);

% arguments
% if isempty( fname ) || isempty( nchans ) 
%     return
% end
% if ~isa( fname, 'char' ) || ~exist( fname, 'file' ) 
%     msg = sprintf( 'missing source %s', fname );
%     rc = -1;
%     return
% end
% % 
% [~,b,c] = fileparts(fname);
% tmpfname = fullfile(outpath,strrep([b '.' num2str(gchans) c],'  ','.'));
% if ~isa( nchans, 'numeric' ) || ~isa( gchans, 'numeric' ) ...
%         || max( gchans ) > nchans || min( gchans ) < 1 ...
%         || sum( gchans ~= round( gchans ) )
%     msg = 'improper format for chans/nchans';
%     rc = -1;
%     return
% end

% % partition into blocks
% info = dir( fname );
% nsamples = info.bytes / nbytes / nchans;
% if ~isequal( nsamples, round( nsamples ) )
%     msg = sprintf( 'incorrect nchans (%d) for file %s', nchans, fname );
%     rc = -1;
%     return
% end
% nblocks = ceil( nsamples / blocksize );
% blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
% blocks( nblocks, 2 ) = nsamples;
% 
% open file for writing
% fid = fopen( tmpfname, 'w' );
% if fid == -1
%     msg = 'cannot open file';
%     rc = fid;
%     return
% end
%  load clu res
 [clu,res] = load_clu_res (path2clu, path2res , clusters2remove);
%  go over blocks and write out
% for i = 1 : nblocks
%     tic;
%     %load dat
%     boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
%     bsize = ( diff( blocks( i, : ) ) + 1 );
%     if i==1
%         m = memmapfile( fname, 'Format', 'int16', 'Offset', max(0,boff-tmplate_time_length*nchans * nbytes), 'Repeat', (bsize+tmplate_time_length)*nchans, 'writable', true );
%         d = reshape( m.data, [ nchans bsize+tmplate_time_length ] );
%     elseif i==nblocks
%         m = memmapfile( fname, 'Format', 'int16', 'Offset', max(0,boff-tmplate_time_length*nchans * nbytes), 'Repeat', (bsize+tmplate_time_length)*nchans, 'writable', true );
%         d = reshape( m.data, [ nchans bsize+tmplate_time_length ] );
%     else
%         m = memmapfile( fname, 'Format', 'int16', 'Offset', max(0,boff-tmplate_time_length*nchans * nbytes), 'Repeat', (bsize+2*tmplate_time_length)*nchans, 'writable', true );
%         d = reshape( m.data, [ nchans bsize+2*tmplate_time_length ] );
%     end
load(fname);
    d=DATAwrite;
    spikes_in_batch=numel(res);
    tmpres=res;
    tmp_cor_M=zeros(N_clusters,spikes_in_batch,2*max_offset+1);
    tmp_amp=zeros(spikes_in_batch,2*max_offset+1);
    for j=1:spikes_in_batch
%         for k=1:N_clusters
            for l=1:2*max_offset+1
%                 if i==1
                    spike_wavform=double(d(:,((tmpres(j)-tmplate_time_length/2+offset_values(l)):...
                      (tmpres(j)+tmplate_time_length/2-1+offset_values(l)))));
%                 else
%                     try
                        % if there are not enough time points to sample
                        % for this spike, break and finish. this happens at
                        % the last spike in the batch - ON
%                         spike_wavform=double(d(:,tmplate_time_length+((tmpres(j)-tmplate_time_length/2+offset_values(l)):...
%                             (tmpres(j)+tmplate_time_length/2-1+offset_values(l)))));
%                     catch
%                         break
%                     end
%                 end
                tmp_amp(j,l)=norm(spike_wavform,2);
                spike_wavform=spike_wavform/tmp_amp(j,l);
                spike_wavform=repmat(spike_wavform,1,1,N_clusters);
                tmp_cor_M(:,j,l)=sum(sum(tmplates(:,:,:).*spike_wavform(:,:,:)))/nchans;
        
            end
%         end
    end
    tmp_cor_M=max(tmp_cor_M,[],3);
%     cor_M=[cor_M tmp_cor_M];
    tmp_amp=max(tmp_amp,[],2);
    tmpliklihod=zeros(N_clusters,spikes_in_batch);
    for k=1:N_clusters
        tmpliklihod(k,:)=normcdf(tmp_amp,tmplat_amplituds(k),amps_std(k));
    end
    liklihod=[liklihod tmpliklihod];
    cor_M = tmp_cor_M;
%     fwrite( fid, d( : ), 'int16' );
%     clear d m spikes_in_batch tmp_cor_M tmp_amp
%     toc;
% end

% % close file
% rc = fclose( fid );
% if rc == -1
%     msg = 'cannot save new file';
%     return
% end



return