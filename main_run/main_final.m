% fpath - path to a folder containing multiple dat files
% nchans - number of channels in each shank for each file
% nchans_tot - number of channels in each file
%% params
name = 'm258r1.dat';
path = 'D:\MATLAB\Test';
fpath = 'D:\MATLAB\Results\test';
nchans = 8;
nchans_tot = 56;
nchans_used = 32;
Fs = 20e3;
overlap_time = 10;
max_overlap_time = 30;
max_time = 40;
path2config1 = 'D:\MATLAB\Results\test\1';
path2config2 = 'D:\MATLAB\Results\test\2-end';
%% append dat files
append_multiple_files(path,fpath,name,nchans_tot);
fprintf('Files appending complete! \n');
%% split files into shanks
split2shanks ( fpath  , nchans, nchans_tot,nchans_used );
fprintf('Files spliting into shanks complete! \n');
%% split files into smaller segments
split_times (fpaths,nchans,nchans_tot,overlap_time,max_time,Fs)   
fprintf('Files spliting into segments complete! \n');
%% copy KS files
copy_KS_files ( fpaths,path2config1,path2config2 );
%% run KS
run_KS ( fpaths )
fprintf('Kilosort run complete!! \n');
%% cluster correspondance
[results,clusters] = correspondance ( fpaths,max_overlap_time,overlap_time,Fs );
%% create OLM res and clu
[OLM_clu,OLM_res] = OLM_res_clu ( fpaths,clusters, overlap_time,max_time,Fs );
%% create RTS res and clu