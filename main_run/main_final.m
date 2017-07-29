% fpath - path to a folder containing multiple dat files
% nchans - number of channels in each shank for each file
% nchans_tot - number of channels in each file
%% params
name = 'm258r1.dat';
path = 'D:\MATLAB\m258r1 - Original - Do NOT Change';
fpath = 'D:\MATLAB\Results\test';
nchans = 8;
nchans_tot = 56;
Fs = [20e3, 20e3, 20e3];
overlap_time = 10;
max_overlap_time = 40;
%% append dat files
append_multiple_files(path,fpath,name,nchans_tot);
fid = fopen(fullfile(fpath,name));
[rc,msg] = append_files(fname,nchans,fid);
%% split files into shanks
[fpaths,Fs,nchans] = split2shanks ( fpath  , nchans, nchans_tot,Fs );
%% split files into smaller segments
split_times (fpaths,nchans,nchans_tot,overlap_time,max_overlap_time,Fs)    