% PARTITION         partition a binary file into multiple files
%
% RC = PARTITION( SOURCEFILE, NEWFILES, PERIODS, NCHANS, PRECISION )
%
% partition sourcefile into newfiles, each composed of the data spanning
% the periods defined in periods (samples). see EXTRACTFILE for more
% details.
% 
% option 1: newfiles can be left empty, then will be filled in according to
% periods with the suffix p001, p002 etc generated automatically added
% before the file extension
% 
% option 2: periods can be either an explicit list of periods (in samples,
% 2-column format) or a 3-element cell array: 
% [ number of files, duration (sec), sampling rate (samples/sec) ]
%
% example 1 (explicit):
% cd /Volumes/Data/phaser4/mouse371/
% rc = partition( 'm371r2.034.dat', { 'm371r2.034p01.dat', 'm371r2.034p02.dat' }, [ 1 ( 10 ) * 20000; 10 * 20000 +  1 ( 20 ) * 20000 ], 56 )
% rc = partition( 'm371r2.035.dat', { 'm371r2.035p1.dat', 'm371r2.035p2.dat', 'm371r2.035p3.dat', 'm371r2.035p4.dat' }...
%   , [ 1 ( 3 * 60 ) * 20000; 3 * 60 * 20000 +  1 ( 6 * 60 ) * 20000; 6 * 60 * 20000 +  1 ( 7 * 60 ) * 20000; 7 * 60 * 20000 +  1 ( 9 * 60 ) * 20000 ]...
%   , 56 )
%
% example 2 (short-hand):
% rc = partition( 'm371r2.034.dat', '', { 3, 10, 20000 }, 56 )
% rc = partition( 'm361r2.032.dat', '', { 3, 120, 20000 }, 56 ) % cut into three 2-min files
%
% see also: EXTRACTFILE, CONCATFILES

% 30-may-12 ES

function rc = partition( sourcefile, newfiles, periods, nchans, precision )

% input arguments
nargs = nargin;
if nargs < 1 || isempty( sourcefile )
    error( 'missing sourcefile' )
end
if nargs < 2 || isempty( newfiles )
    newfiles = [];
end
if nargs < 3 || isempty( periods )
    error( 'missing periods' )
end
if isa( periods, 'double' )
    if sum( sum( periods ~= round( periods ) ) ) || sum( sum( periods <= 0 ) ) || ~ismember( size( periods, 2 ), [ 0 2 ] )
        error( 'periods should be a 2-column matrix of non-negative integers' )
    end
elseif isa( periods, 'cell' )
    if ~isequal( size( periods ), [ 1 3 ] )
        error( 'periods should be a 3-element cell array: number of files, number of seconds/file, sampling rate' )
    end
    nfiles = periods{ 1 };
    durs = periods{ 2 };
    Fs = periods{ 3 };
    durs = durs * Fs;
    periods = [ 1 : durs : durs * nfiles; durs : durs : durs * nfiles ]';
end
if nargs < 4 || isempty( nchans )
    nchans = 32;
end
if nchans <= 0 || nchans ~= round( nchans ), error( 'nchans should be a non-negative integer' ), end
if nargs < 5 || isempty( precision )
    precision = 'int16';
end

% determine the newfile names
if isempty( newfiles )
    [ pathname basename ext ] = fileparts( sourcefile );
    if ~isempty( pathname )
        pathname = [ pathname '/' ];
    end
    for fnum = 1 : size( periods, 1 )
        newfiles{ fnum } = sprintf( '%s%sp%s%s', pathname, basename, num2str( fnum, 3 ), ext );
    end
end

% make sure newfiles and periods match
if length( newfiles ) ~= size( periods, 1 )
    error( 'newfiles and periods should be the same length' )
end

% actually extract the files
for fnum = 1 : length( newfiles )
    newfile = newfiles{ fnum };
    if strcmp( newfile, sourcefile )
        fprintf( 1, 'cannot overwrite' )
        continue
    end
    rc( fnum ) = extractfile( sourcefile, newfile, periods( fnum, : ), nchans, precision );
end

return

% EOF

% example of use - distribute eeg files back:
filebase = datenum2filebase( { '26nov11', -1 } )

% prepare
[ pathname filename extname ] = fileparts( filebase );
filename = [ filename extname ];
par = LoadXml( filebase );
[ srslen, fnums, fnames ] = makesrslen( filebase, [], -2 );
sourcefile = [ filename '.eeg' ];
newfiles = fnames;
for i = 1 : length( newfiles ), newfiles{ i } = [ fnames{ i } '.eeg' ]; end
periods = [ cumsum( [ 1; srslen( 1 : end - 1 ) ] ) cumsum( srslen ) ];
nchans = par.nChannels;
precision = 'int16';

% actually distribute
tic
cd0 = pwd;
cd( pathname )
rc = partition( sourcefile, newfiles, periods, nchans, precision )
cd( cd0 )
toc % 15 sec for a 0.5GB eeg file

% test equality (assuming there are orignial files in the original directories)
tic
for i = 1 : length( fnames )
    fname0 = [ fileparts( pathname ) '/' fnames{ i } '/' fnames{ i } '.eeg' ];
    fname1 = [ pathname '/' newfiles{ i } ];
    a0 = memmapfile( fname0, 'format', 'int16' );
    a1 = memmapfile( fname0, 'format', 'int16' );
    d0 = a0.Data;
    d1 = a1.Data;
    [ i isequal( d0, d1 ) ]
    clear a0
    clear a1
end
toc % 5 sec to check...

% or move them to the original direcotires (assuming such exist)
tic
for i = 1 : length( fnames )
    cmd = [ '!mv -v ' pathname '/' newfiles{ i } ' ' fileparts( pathname ) '/' fnames{ i } '/' ];
    eval( cmd )
end
toc

% write a process clean that will make sure the eeg is merged, srs and
% srslen exist. then it will remove the eeg files from the source
% directories; run this on every sesion that has finished processing
% 
% the critical things are
% (1) whl file - make sure led file was generated,
% and that whl file is created. best to make sure it have been merged too
% (mergewhl)
% (2) stm - make sure were created properly. for some animals (the rats..)
% i changed the channel/diode correspondence between files and thats messy.
% the stimulus extraction should be 100% from the merged eeg file though
% (at least no worse than from the source eeg)


