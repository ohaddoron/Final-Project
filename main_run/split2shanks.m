function fpaths = split2shanks ( fpath, nchans, nchans_tot, nchans_used )

%% init
files = dir(fullfile(fpath,'*.dat'));
nFiles = length(files);
fpaths = {};
for f = 1 : nFiles
    %% cycle through files
    fname = fullfile(fpath,files(f).name);
    for c = 1 : nchans_used / nchans;
        %% cycle through channels
        cur_path = fullfile(strrep(strrep(fname,'.dat',''),'.','_'),sprintf('%d - %d',(c-1) * nchans + 1, c * nchans));
        fpaths = cat(1,fpaths,{cur_path});
        if ~exist(cur_path,'file');
            mkdir(fullfile(cur_path));
        end
        getchannels(fname,cur_path,nchans_tot,(c-1) * nchans+ 1 : c * nchans);
    end
end 