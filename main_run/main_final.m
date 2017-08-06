% fpath - path to a folder containing multiple dat files
% nchans - number of channels in each shank for each file
% nchans_tot - number of channels in each file
%% params
name = 'm258r1.dat';
path = 'D:\MATLAB\m258r1.286 - Testing';
fpath = 'D:\MATLAB\Results\test';
nchans = 8;
nchans_tot = 56;
nchans_used = 32;
Fs = 20e3;
overlap_time = 10;
max_overlap_time = 30;
offset_val = 3;
max_time = 40;
template_time_length = 82;
path2config1 = 'D:\MATLAB\Results\test\1';
path2config2 = 'D:\MATLAB\Results\test\2-end';
remove_noise = true;
n_spikes_threshold = 1000; % minimal number of spikes for a cluster to be concidered
%% append dat files
append_multiple_files(path,fpath,name,nchans_tot);
fprintf('Files appending complete! \n');
%% split files into shanks
fpaths = split2shanks ( fpath  , nchans, nchans_tot,nchans_used );
fprintf('Files spliting into shanks complete! \n');
%% split files into smaller segments
split_times (fpaths,nchans,nchans_tot,overlap_time,max_time,Fs)   
fprintf('Files spliting into segments complete! \n');
%% copy KS config files
copy_KS_files ( fpaths,path2config1,path2config2 );
%% run KS for split
run_KS ( fpaths )
%% move dat files and run KS
dat_paths = move_dat_files ( fpaths,path2config1 );
run_KS ( dat_paths )
copy_KS_files_full ( dat_paths,path2config1 );
run_kilosort(dat_paths)
fprintf('Kilosort run complete! \n');
%% copy KS RTS clu and res
KS_res_clu ( dat_paths , remove_noise ) ;
%% cluster correspondance
[~,clusters] = correspondance ( fpaths,max_overlap_time,overlap_time,Fs,remove_noise );
%% create OLM res and clu
post_process_clusters = OLM_res_clu ( fpaths,clusters, overlap_time,max_time,Fs );
%% create RTS res and clu
RTS_res_clu(fpaths,offset_val,overlap_time,max_time,Fs,clusters,template_time_length,n_spikes_threshold)
%% Comparison functions
results = compare_methods ( fpaths, offset_val,post_process_clusters );
