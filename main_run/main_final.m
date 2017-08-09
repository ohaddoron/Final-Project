% fpath - path to a folder containing multiple dat files
% nchans - number of channels in each shank for each file
% nchans_tot - number of channels in each file
%% params
name = 'm258r1.dat';
% path = 'D:\MATLAB\m258r1.286 - Testing';
original_path = 'D:\MATLAB\testset';
% fpath = 'D:\MATLAB\Results\test';
original_fpath = 'D:\MATLAB\Results\test';
path2figures = fullfile(original_fpath,'figures');
if ~exist(path2figures,'dir'), mkdir(path2figures), end
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
clusters2remove = 0;
n_spikes_threshold = 1000; % minimal number of spikes for a cluster to be concidered
folders = dir(original_path);
folders(1:2) = [];
folders(~[folders.isdir]) = [];
nFolders = length(folders);
clusters = cell(nFolders,1);
post_process_clusters = cell(nFolders,1);
comparison_results = cell(nFolders,1);
detection_results = cell(nFolders,1);
OLM_RTS_results = cell(nFolders,1);
tmp_fpaths = cell(nFolders,1);
dat_paths = cell(nFolders,1);
%%
for i = 1 : nFolders
    path = fullfile(original_path,folders(i).name);
    fpath = fullfile(original_fpath,folders(i).name);
    if ~exist(fpath,'dir')
        mkdir(fpath);
    end
    name = strcat(folders(i).name,'.dat');
    %% append dat files
    append_multiple_files(path,fpath,name,nchans_tot);
    fprintf('Files appending complete! \n');
    %% split files into shanks
    tmp_fpaths{i} = split2shanks ( fpath  , nchans, nchans_tot,nchans_used );
    fpaths = tmp_fpaths{i};
    fprintf('Files spliting into shanks complete! \n');
    %% split files into smaller segments
    split_times (fpaths,nchans,nchans_tot,overlap_time,max_time,Fs)   
    fprintf('Files spliting into segments complete! \n');
end
%%
for i = 2 : nFolders
    fpaths = tmp_fpaths{i};
    %% copy KS config files
    copy_KS_files ( fpaths,path2config1,path2config2 );
    %% run KS for split
    run_KS ( fpaths )
end 
%%
for i = 1 : nFolders
    %% move dat files and run KS
    fpaths = tmp_fpaths{i};
    fclose all;
    dat_paths{i} = move_dat_files ( fpaths );
end
%%
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};
    copy_KS_files_full ( dat_paths{i},path2config1 );
    run_kilosort(dat_paths{i})
    fprintf('Kilosort run complete! \n');
end
%% copy KS RTS clu and res
for i = 1 : nFolders
    KS_res_clu ( dat_paths{i} , remove_noise ) ;
end
%% cluster correspondance
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};
    [~,clusters{i}] = correspondance ( fpaths,max_overlap_time,overlap_time,Fs,remove_noise );
end
%% create OLM res and clu
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};
    post_process_clusters{i} = OLM_res_clu ( fpaths,clusters{i}, overlap_time,max_time,Fs );
end
%% create RTS res and clu
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};
    RTS_res_clu(fpaths,offset_val,overlap_time,max_time,Fs,clusters{i},template_time_length,n_spikes_threshold)
end
%% Comparison functions
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};   
    comparison_results{i} = compare_methods ( fpaths, offset_val,post_process_clusters{i} );
end
%% Compare detection
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};   
    detection_results{i} = detection_comparison ( fpaths , offset_val );
end
%% compare OLM RTS
for i = 1 : nFolders
    fpaths = tmp_fpaths{i};
    OLM_RTS_results{i} = compare_OLM_RTS_wrapper ( fpaths,offset_val,post_process_clusters{i},...
        Fs,overlap_time,nchans,clusters2remove,template_time_length );
end
%% visualize
visualize_detection ( detection_results,path2figures )
visualize_f_half ( comparison_results,path2figures )
visualize_trough2peak_vs_LT ( fpaths,Fs )