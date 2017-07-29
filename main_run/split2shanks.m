function [fpaths,fs,nChans] = split2shanks ( fpath, nchans, nchans_tot,Fs )

%% init
files = dir(fullfile(fpath,'*.dat'));
nFiles = length(files);
fpaths = {};
fs = [];
nChans = [];
for f = 1 : nFiles
    %% cycle through files
    fname = fullfile(fpath,files(f).name);
    for c = 1 : nchans_tot(f) / nchans(f);
        %% cycle through channels
        cur_path = fullfile(strrep(strrep(fname,'.dat',''),'.','_'),sprintf('%d - %d',(c-1) * nchans(f) + 1, c * nchans(f)));
        fpaths = cat(1,fpaths,{cur_path});
        fs(end+1) = Fs(f);
        nChans(end+1) = nchans(f);
        if ~exist(cur_path,'file');
            mkdir(fullfile(cur_path));
        end
        [r,cx] = getchannels(fname,cur_path,nchans_tot(f),(c-1) * nchans(f)+ 1 : c * nchans(f));
    end
end 