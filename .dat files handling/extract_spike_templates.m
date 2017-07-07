function mean_wave_forms = extract_spike_templates( fname,nchans,outpath,cluname,resname,samples_per_spike)

%% initialize output
rc = 0;
msg = '';

%% constants
nbytes = 2;         % [bytes/sample]
blocksize = 1e6;    % [samples/channel]

%% Input Check
if isempty( fname ) || isempty( nchans ) || isempty(cluname) || isempty(resname)
    return
end
if ~isa( fname, 'char' ) || ~exist( fname, 'file' )  
    msg = sprintf( 'missing source %s', fname );
    rc = -1;
    return
end

if ~isa( cluname, 'char' ) || ~exist( cluname, 'file' )  
    msg = sprintf( 'missing cluster files %s', cluname );
    rc = -1;
    return
end

if ~isa( resname, 'char' ) || ~exist( resname, 'file' )  
    msg = sprintf( 'missing results files %s', resname );
    rc = -1;
    return
end


[~,b,c] = fileparts(fname);
tmpfname = fullfile(outpath,'Spike_Templates.txt');
if ~isa( nchans, 'numeric' ) 
    msg = 'improper format for chans/nchans';
    rc = -1;
    return
end

%% partition into blocks
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


%% Load res and clu files

res = load(resname); 
clu = load(cluname) + 1;
clu(1) = []; % Remove the number of clusters, irrelevant data
%% check num of spikes per cluster
clu_id = unique(clu);
num_of_clusters = length(clu_id);
n_spikes = 0;
for i = 1 : num_of_clusters
    n_spikes = max([n_spikes,sum(clu==clu_id(i))]);
end
raw_spike_templates = nan(n_spikes,num_of_clusters,nchans,samples_per_spike);
%% Extract spikes and write to file
for i = 1 : nblocks
    boff = ( blocks( i, 1 ) - 1 ) * nbytes * nchans;
    bsize = ( diff( blocks( i, : ) ) + 1 );
    cur_idx = res > blocks(i,1) & res < blocks(i,2); % in range of the current block
    cur_res = res(cur_idx) - (i-1)*bsize; % center back 
    cur_clu = clu(cur_idx);
    m = memmapfile( fname, 'Format', 'int16', 'Offset', boff, 'Repeat', bsize * nchans, 'writable', true );
    d = reshape( m.data, [ nchans bsize ] );
    for k = 1 : length(cur_res)
        try
            cur_template = d(:,cur_res(k)-floor(samples_per_spike/2):cur_res(k)+floor(samples_per_spike)/2 -1);
        catch
            ...
        end
        raw_spike_templates(k,cur_clu(k),:,:) = cur_template;
    end 
%     fwrite( fid, d( : ), 'int16' );
    clear d m 
end

mean_wave_forms = nan(nchans,samples_per_spike,num_of_clusters);
% mean_wave_forms = nanmean(raw_spike_templates);
figure;
for i = 1 : num_of_clusters
    cur_wave_form = squeeze(raw_spike_templates(:,i,:,:));
    mean_wave_forms(:,:,i) = nanmean(cur_wave_form);
    subplot(6,4,i);
    imagesc(mean_wave_forms(:,:,i));
    
    
end
a = 1;
    
    