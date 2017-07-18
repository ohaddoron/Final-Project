function res = spikeDetection ( fname, nchans,template_time_length )


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
if ~isa( nchans, 'numeric' ) 
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



spike_times = cell(1,nblocks);

for i = 1 : nblocks
    boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
    bsize = ( diff( blocks( i, : ) ) + 1 );
    m = memmapfile( fname, 'Format', 'int16', 'Offset', boff, 'Repeat', bsize * nchans, 'writable', true );
    d = reshape( m.data, [ nchans bsize ] );
    d=min(d,[],1);
    threshold = -4.5*std(double(d(:)));
    [~,spike_times{i}] = find(d(2:end-1) < threshold  & d(1:end-2) > d(2:end-1)...
        & d(3:end) > d(2:end-1));

    spike_times{i} = (spike_times{i} + blocks(i,1))';

    
    
    
end
spike_times{1}(spike_times{1} < template_time_length/2 ) = [];
spike_times{end}(spike_times{end} > max(blocks(:)) - template_time_length/2) = [];
res = cat(1,spike_times{:});
return

