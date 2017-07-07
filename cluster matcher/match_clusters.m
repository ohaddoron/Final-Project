function [match_score,result] = match_clusters( fpath,clusters2remove,...
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
clusters1 = unique(clu1);
nClusters1 = length(clusters1);
[clu2,res2] = load_clu_res(path2clu2,path2res2,clusters2remove2);
clusters2 = unique(clu2);
nClusters2 = length(clusters2);
%% read spikes
spk1 = read_spikes( fname1 ,nchans,template_time_length,clu1,res1);
spk1 = permute(spk1,[3 2 1]);
[nSpikes,nSamples,nchans] = size(spk1);
spk2 = read_spikes( fname2 ,nchans,template_time_length,clu2,res2);
[~,nSamples2,nSpikes2] = size(spk2);

%% Find PCA coeff and score
score = zeros(nchans,nSpikes,N_PC);
coeff = zeros(nchans,nSamples,N_PC);
for chan = 1 : nchans
    [coeff_tmp,score_tmp] = pca(spk1(:,:,chan),'NumComponents',N_PC);
    score(chan,:,:) = score_tmp;
    coeff(chan,:,:) = coeff_tmp;
end
score=permute(score,[3 1 2]); % nchannels X nFeature X nSpikes
score = reshape(score(:),N_PC * nchans, nSpikes)';

%% clc score for  spk2
score2 = zeros(nchans,N_PC,nSpikes2);
for iSpikes2 = 1 : nSpikes2
    cur_spk = spk2(:,:,iSpikes2);
    for iPC = 1 : N_PC
        score2( :,iPC,iSpikes2)=diag(cur_spk * coeff(:,:,iPC)');
    end
    
end
score2=permute(score2,[2 1 3]);
score2 = reshape(score2(:),N_PC * nchans, nSpikes2)';
%% match score according to mahal dis 
match_score = zeros(nClusters1,nClusters2);
for iClusters1 = 1 : nClusters1
    idx1 = clu1 == clusters1(iClusters1);
    oSpikes = score(idx1,:);
    for iClusters2 = 1 : nClusters2
        idx2 = clu2 == clusters2(iClusters2);
        nSpikes = score2(idx2,:);
        d = mahal(nSpikes,oSpikes);
        probs = 1 - chi2cdf(d,N_PC * nchans);
        match_score(iClusters1,iClusters2) = geomean(probs);
    end    
end
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
figure, imagesc(match_score)
colorbar
tmp_match_score=match_score;
%% D threshold part 2/2
% tmp_match_score(ID1<30,:)=0;
% tmp_match_score(:,ID2<30)=0;
%% matcher monogamy mathcing with threshold of 0.01
result=nan(nClusters2,1);
while max(tmp_match_score(:))>0.01
    [~,idx]=max(tmp_match_score(:));
    [R,C]=ind2sub(size(tmp_match_score),idx);
    result(C)=R;
    tmp_match_score(R,:)=0;
    tmp_match_score(:,C)=0;
end
return