fpaths = get_data;

nPaths = length(fpaths);
nchans = 8;
threshold = -1000;
TP = zeros(nPaths,1);
FP = zeros(nPaths,1);
offset = 1;
for k = 1 : nPaths
    cur_path = fpaths{k};
    fname = fullfile(cur_path,'temp_wh.dat');
    files = dir(fullfile(cur_path,'*res.2'));
    res1 = load(fullfile(cur_path,files.name));
    
    res2 = spikeDetection(fname,nchans);
    
    [TP(k),FP(k)] = match_res(res1,res2,offset);
end

TP = 100 * TP;
FP = 100 * FP;

mTP = mean(TP);
mFP = mean(FP);
sTP = std(TP);
sFP = std(FP);

figure, bar(1:2, [mTP mFP]), hold on;
errorbar(1:2,[mTP mFP],[sTP sFP],'.');

    
    