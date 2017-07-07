% split data into multiple time frames
%
% [ rc, msg ] = split( fname, nchans, chans )
% 
% fname         full file name 
% nchans        number of channels
%



function [rc,msg] = split(fname,outpath,nchans,nsplits)
% initialize output
rc = 0;
msg = '';

% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]

% arguments
if isempty( fname ) || isempty( nchans )
    return
end
if ~isa( fname, 'char' ) || ~exist( fname, 'file' ) 
    msg = sprintf( 'missing source %s', fname );
    rc = -1;
    return
end

[~,b,c] = fileparts(fname);


% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
nsamples_splits = ceil(nsamples/nsplits);
if ~isequal( nsamples, round( nsamples ) )
    msg = sprintf( 'incorrect nchans (%d) for file %s', nchans, fname );
    rc = -1;
    return
end
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;


% open file for writing


% go over blocks and write out


split = 1;
d = [];
i = 1;
while i <= nblocks || ~isempty(d)
    if i <= nblocks
        boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
        bsize = ( diff( blocks( i, : ) ) + 1 );
        m = memmapfile( fname, 'Format', 'int16', 'Offset', boff, 'Repeat', bsize * nchans, 'writable', true );
        s = reshape( m.data, [ nchans bsize ] );

        d = cat(2,d,s);
    end
    if size(d,2) > nsamples_splits || i >= nblocks
        [~,b,c] = fileparts(fname);
        tmpfname = fullfile(outpath,strrep([b ' split' num2str(split) c],'  ','.'));
        fid = fopen( tmpfname, 'w' );
        if fid == -1
            msg = 'cannot open file';
            rc = fid;
            return
        end
        try
            r = d(:,1:nsamples_splits);
        catch
            r = d(:,1:end);
        end
        fwrite( fid, r( : ), 'int16' );
        fclose(fid);
        try
            d(:,1:nsamples_splits) = [];
        catch
            d(:,1:end) = [];
        end
        split = split + 1;
    end
    i = i + 1;
    clear m
end

    





return