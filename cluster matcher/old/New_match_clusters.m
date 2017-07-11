function [match_score,result] = New_match_clusters( fpath,clusters2remove,...
    nchans,template_time_length,origin)
%% constants
N_PC = 3;

%% file generation
fpath1 = fpath{1};
fpath2 = fpath{2};

files1 = dir(fpath1);
clu_idx = ~cellfun(@isempty,strfind({files1.name},'.clu.'));
res_idx = ~cellfun(@isempty,strfind({files1.name},'.res.'));
wh_idx = ~cellfun(@isempty,strfind({files1.name},'temp_wh'));
path2clu1 = fullfile(fpath1,files1(clu_idx).name);
path2res1 = fullfile(fpath1,files1(res_idx).name);
fname1 = fullfile(fpath1,files1(wh_idx).name);

files2 = dir(fpath2);
clu_idx = ~cellfun(@isempty,strfind({files2.name},'.clu.'));
res_idx = ~cellfun(@isempty,strfind({files2.name},'.res.'));
wh_idx = ~cellfun(@isempty,strfind({files2.name},'temp_wh'));
path2clu2 = fullfile(fpath2,files2(clu_idx).name);
path2res2 = fullfile(fpath2,files2(res_idx).name);
fname2 = fullfile(fpath2,files2(wh_idx).name);



if origin == 1
    clusters2remove1 = clusters2remove{1};
    clusters2remove2 = clusters2remove{2};
elseif origin == 2
    fname1 = fname{2};
    fname2 = fname{1};
    path2clu1 = path2clu{2};
    path2clu2 = path2clu{1};
    path2res1 = path2res{2};
    path2res2 = path2res{1};
    clusters2remove1 = clusters2remove{2};
    clusters2remove2 = clusters2remove{1};
end
%% read clus
[clu1,res1] = load_clu_res (path2clu1, path2res1 , clusters2remove1);
clusters1 =1: max(clu1);
nClusters1 = max(clusters1);
[clu2,res2] = load_clu_res(path2clu2,path2res2,clusters2remove2);
clusters2 = 1: max(clu2);
nClusters2 = max(clusters2);
%% read spikes
spk1 = read_spikes( fname1 ,nchans,template_time_length,clu1,res1);
[nchans,nSamples,nSpikes1] = size(spk1);
spk2 = read_spikes( fname2 ,nchans,template_time_length,clu2,res2);
[~,~,nSpikes2] = size(spk2);
spk1=permute (spk1,[3,1,2]);

spk2=permute (spk2,[3,1,2]);
%% clc mean and sd of spiks
idx1=false(nSpikes1,nClusters1);
mu1=zeros(nchans,nSamples,nClusters1);
sd1=zeros(nchans,nSamples,nClusters1);
N1=zeros(nClusters1,1);
for iClusters1 = 1 : nClusters1
    idx1(:,iClusters1) = clu1 == clusters1(iClusters1);
    N1(iClusters1)=sum(idx1(:,iClusters1));
    mu1(:,:,iClusters1)=mean(spk1(idx1(:,iClusters1),:,:),1);
    sd1(:,:,iClusters1)=std(spk1(idx1(:,iClusters1),:,:),0,1);
end
idx2=false(nSpikes2,nClusters2);
mu2=zeros(nchans,nSamples,nClusters2);
sd2=zeros(nchans,nSamples,nClusters2);
N2=zeros(nClusters2,1);
for iClusters2 = 1 : nClusters2
    idx2(:,iClusters2) = clu2 == clusters2(iClusters2);
    N2(iClusters2)=sum(idx2(:,iClusters2));
    mu2(:,:,iClusters2)=mean(spk2(idx2(:,iClusters2),:,:),1);
    sd2(:,:,iClusters2)=std(spk2(idx2(:,iClusters2),:,:),0,1);
end
match_score=zeros(nClusters1,nClusters2);
for iClusters1 = 1 : nClusters1
    for iClusters2 = 1 : nClusters2
%         O_score=abs(mu1(:,:,iClusters1)-mu2(:,:,iClusters2))./sqrt(sd2(:,:,iClusters2).^2+sd1(:,:,iClusters1).^2);
%         match_score(iClusters1,iClusters2)=mean(O_score(:));
%         oCluster = mu1(:,:,iClusters1);
%         nCluster = mu2(:,:,iClusters2);
        [~,tmp_score ] = ttest2(spk1(idx1(:,iClusters1),:,:),...
            spk2(idx2(:,iClusters2),:,:),'Vartype','unequal');
        match_score(iClusters1,iClusters2)=mean(tmp_score(:));
        figure;
        subplot(2,2,3)
        imagesc(squeeze(tmp_score));
        subplot(2,2,1)
        imagesc(squeeze(mu1(:,:,iClusters1)))
        subplot(2,2,2)
        imagesc(squeeze(mu2(:,:,iClusters2)))
        subplot(2,2,4)
        imagesc(abs((mu1(:,:,iClusters1)-mu2(:,:,iClusters2))./...
            sqrt((sd1(:,:,iClusters1).^2+sd2(:,:,iClusters2).^2))))  
%           imagesc(log10(abs(2*(mu1(:,:,iClusters1)-mu2(:,:,iClusters2))./...
%             ((mu1(:,:,iClusters1)+mu2(:,:,iClusters2)).*sqrt((sd1(:,:,iClusters1).^2+sd2(:,:,iClusters2).^2))))))
    end    
end

match_score = 1 - match_score;
% This is done just so it would align with the original purpose here which
% was to find the minimal distance. The highest probability would be given
% to two simular populations, we want for the two populations to have the
% minial score
%% ID threshold part 1/2
% fpath1 = fileparts(fname1);
% fpath2 = fileparts(fname2);
% resOffest = 1;
% clusterMethod = 'KS';
% [~,~,ID1] = PCA_analysis...
%     (fpath1,nchans,template_time_length,clusters2remove1,...
%     clusterMethod,resOffest,[]);
% [~,~,ID2] = PCA_analysis...
%     (fpath2,nchans,template_time_length,clusters2remove2,...
%     clusterMethod,resOffest,[]);
%% ploting
% figure, imagesc(match_score)
% colorbar
tmp_match_score=match_score;
%% D threshold part 2/2
% tmp_match_score(ID1<30,:)=0;
% tmp_match_score(:,ID2<30)=0;
%% N threshold
tmp_match_score(N1<1e3,:)=inf;
tmp_match_score(:,N2<1e3)=inf;
%% matcher monogamy mathcing with threshold of 0.06 sholed replace threshold with 
% https://en.wikipedia.org/wiki/Welch%27s_t-test and a more intuitive score
result=nan(nClusters2,1);
% I removed the N threshold for now. Not sure what it is, we should
% discuss. Also, I set the threshold to 0.8 (meaning htat we have a match
% of above 0.2 (1-0.2). I don't know if this is too high. We should
% discuss
while min(tmp_match_score(:))< 0.8
    [~,idx]=min(tmp_match_score(:));
    [R,C]=ind2sub(size(tmp_match_score),idx);
    result(C)=R;
    tmp_match_score(R,:)=inf;
    tmp_match_score(:,C)=inf;
%     figure, imagesc(tmp_match_score);
end
return