function merge (fpath, merge_vector, outpath,nchans)

files = dir(fullfile(fpath,'*.dat'));

tmpfname = fullfile(outpath,'merged file.dat');
fid = fopen(tmpfname,'w');
for i = 1 : length(merge_vector)
    fname = fullfile(fpath,files(merge_vector(i)).name);
    append_files(fname,nchans,fid);
end
fclose(fid);



