% CONCATFILES         concatenate multiple binary files
%
% RC = CONCATFILES( SOURCEFILES, NEWFILE, NCHANS, PRECISION )
%
% concatenate multiple binary files into a single file head to tail
% all files should have the same channel count and precision
%
% use example:
% cd /Volumes/Data/phaser4/mouse371/
% concatfiles( { 'm371r2.035p1.dat', 'm371r2.035p2.dat', 'm371r2.035p3.dat', 'm371r2.035p4.dat' }, 'm371r2.035.dat', 56 )
%
% see also: EXTRACTFILE, PARTITION

% 30-may-12 ES

function concatfiles( sourcefiles, newfile, nchans, precision )

% input arguments
nargs = nargin;
if nargs < 2 || isempty( sourcefiles ) || isempty( newfile ) || isempty( nchans )
    error( 'missing input parameters' )
end
if nchans <= 0 || nchans ~= round( nchans ), error( 'nchans should be a non-negative integer' ), end
if nargs < 4 || isempty( precision )
    precision = 'int16';
end

BLOCKSIZE = 2^20; % number of elements/block (not bytes)

% build the type casting string
precisionstr = sprintf( '*%s', precision );

% determine number of bytes/sample/channel
a = ones( 1, 1, precision );
sourceinfo = whos( 'a' );
nbytes = sourceinfo.bytes;

% open file for writing
fp1 = fopen( newfile, 'w' );
if fp1 == -1, error( 'fopen error' ), end

for fnum = 1 : length( sourcefiles )

    % check input file
    sourcefile = sourcefiles{ fnum };
    if ~exist( sourcefile, 'file' )
        fprintf( 1, 'missing file %s; skipping this file\n', sourcefile )
        continue
    end
    fileinfo = dir( sourcefile );
    nelements = floor( fileinfo( 1 ).bytes / nbytes );
    
    % open file for reading
    fp0 = fopen( sourcefile, 'r' );
    if fp0 == -1, error( 'fopen error' ), end

    % go over the sourcefile in blocks and write to the newfile
    nblocks = ceil( nelements / BLOCKSIZE );
    for bnum = 1 : nblocks
        if bnum == nblocks
            toload = nelements - ( nblocks - 1 ) * BLOCKSIZE;
        else
            toload = BLOCKSIZE;
        end
        data1 = fread( fp0, toload, precisionstr );
        fwrite( fp1, data1, precision );
    end
    
    % close source file
    fclose( fp0 );
end

% close output file
fclose( fp1 );

return

% EOF
cd /media/psf/Host/Volumes/Data/phaser4/mouse361/m361r2/dat
concatfiles( { 'm361r2.032p001.dat', 'm361r2.032p002.dat', 'm361r2.032p003.dat' }, 'm361r2.032.dat', 56 )

% concatenate a large number of pieces (20-nov-12)
basedir = '/Volumes/Data/phaser7/mouse558/m558r2/dat';
basestr = 'm558r2.019'; 
segnums = 1 : 15;

basedir = '/Volumes/Data/phaser7/mouse558/m558r2/dat';
basestr = 'm558r2.025'; 
segnums = 1 : 11;

basedir = '/Volumes/My Passport/phaser7/mouse260/m260r1/dat/m260r1.053/';
basestr = 'm260r1.053'; 
segnums = 1 : 17;

cd0 = pwd;
cd( basedir )
str = ''; 
for i = segnums; 
    str = sprintf( '%s ''%sp%s.dat''', str, basestr, num3str( i, 3 ) ); 
end
cmd = sprintf( 'concatfiles( { %s }, ''%s.dat'', 56 )', str, basestr );
eval( cmd )
cd( cd0 )

