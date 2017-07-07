% load channels from data file
%
% [ rc, msg ] = removechannels( fname, nchans, chans )
% 
% fname         full file name 
% nchans        number of channels
% gchans        channels to get
%
% does
% writes a new file without the chans
%
% see also      removedcoffset, reorderchannels

function data = loadchannels(fname,nchans,gchans)

rc = 0;
msg = '';

% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]

% arguments
if isempty( fname ) || isempty( nchans ) || isempty( gchans )
    return
end
if ~isa( fname, 'char' ) || ~exist( fname, 'file' ) 
    msg = sprintf( 'missing source %s', fname );
    rc = -1;
    return
end

[a,b,c] = fileparts(fname);
tmpfname = fullfile(a,strrep([b '.' num2str(gchans) c],'  ','.'));
if ~isa( nchans, 'numeric' ) || ~isa( gchans, 'numeric' ) ...
        || max( gchans ) > nchans || min( gchans ) < 1 ...
        || sum( gchans ~= round( gchans ) )
    msg = 'improper format for chans/nchans';
    rc = -1;
    return
end

% partition into blocks
info = dir( fname );
nsamples = info.bytes / nbytes / nchans;
if ~isequal( nsamples, round( nsamples ) )
    msg = sprintf( 'incorrect nchans (%d) for file %s', nchans, fname );
    rc = -1;
    return
end
nblocks = ceil( nsamples / blocksize );
blocks = [ 1 : blocksize : blocksize * nblocks; blocksize : blocksize : blocksize * nblocks ]';
blocks( nblocks, 2 ) = nsamples;

data = [];
for i = 1 : nblocks
    boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
    bsize = ( diff( blocks( i, : ) ) + 1 );
    m = memmapfile( fname, 'Format', 'int16', 'Offset', boff, 'Repeat', bsize * nchans, 'writable', true );
    d = reshape( m.data, [ nchans bsize ] );
    d( ~ismember(1:nchans,gchans), : ) = [];
%     fwrite( fid, d( : ), 'int16' );
    data = cat(2,data,d);
    clear d m
    
end
% fclose(fid);