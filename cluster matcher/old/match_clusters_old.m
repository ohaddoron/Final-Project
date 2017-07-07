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
%     fname1 = fname{1};
%     fname2 = fname{2};
%     path2clu1 = path2clu{1};
%     path2clu2 = path2clu{2};
%     path2res1 = path2res{1};
%     path2res2 = path2res{2};
    clusters2remove1 = clusters2remove{1};
    clusters2remove2 = clusters2remove{2};
%     path2templates1 = path2templates{1};
%     path2templates2 = path2templates{2};
elseif origin == 2
    fname1 = fname{2};
    fname2 = fname{1};
    path2clu1 = path2clu{2};
    path2clu2 = path2clu{1};
    path2res1 = path2res{2};
    path2res2 = path2res{1};
    clusters2remove1 = clusters2remove{2};
    clusters2remove2 = clusters2remove{1};
%     path2templates1 = path2templates{2};
%     path2templates2 = path2templates{1};
end
%% read spikes
[clu,res] = load_clu_res (path2clu1, path2res1 , clusters2remove1);
spk = read_spikes( fname1 ,nchans,template_time_length,clu,res);
spk = permute(spk,[3 2 1]);
[nSpikes,nSamples,nchans] = size(spk);

%% Find PCA
score = zeros(nchans,nSpikes,N_PC);
coeff = zeros(nchans,nSamples,N_PC);
for chan = 1 : nchans
    [coeff_tmp,score_tmp] = pca(spk(:,:,chan),'NumComponents',N_PC);
    score(chan,:,:) = score_tmp;
    coeff(chan,:,:) = coeff_tmp;
end
score=permute(score,[3 1 2]); % nchannels X nFeature X nSpikes
% score = permute(score,[1 3 3]);
score = reshape(score(:),N_PC * nchans, nSpikes)';

% score=reshape(permute(score,[2 1 3]) ,[nchans*N_PC,nSpikes]);
% load(path2templates2);
% nTemplates = size(merged_templates,3);
% templates_score = zeros(nchans,N_PC,nTemplates);
% for iTemplates = 1 : nTemplates
%     cur_template = merged_templates(:,:,iTemplates);
%     for iPC = 1 : N_PC
%         templates_score( :,iPC,iTemplates)=diag(cur_template * coeff(:,:,iPC)');
%     end
%     
% end
% templates_score=permute(templates_score,[2 1 3]);
% templates_score = reshape(templates_score(:),N_PC * nchans, nTemplates)';
        
        
%% build GMM
clusters = unique(clu);
nClusters = length(clusters);
% d = zeros(nSpikes,nClusters);
% % d2 = zeros(nTemplates,nClusters);
% for iCluster = 1 : nClusters
%     idx = clusters(iCluster) == clu;
%     cur_spikes = score(idx,:);
%  
%     d(:,iCluster) = mahal(score,cur_spikes);
% %     d2(:,iCluster) = mahal(templates_score,cur_spikes);
% end
% probs = 1 - chi2cdf(d,N_PC * nchans);
%% 
% for iCluster = 1 : nClusters
%     idx = clu == iCluster;
% %     figure, hold on;
%     [counts1,centers1] = hist(probs(idx,iCluster),50);
%     [counts2,centers2] = hist(probs(~idx,iCluster),50);
%     c1 = cumsum(counts1); c2 = cumsum(counts2);
% %     bar([c1/max(c1); c2/max(c2)]','barwidth',2);
% %     axis tight;
% %     set(gca,'XTickLabel',round(centers1(get(gca,'XTick')),1));
% end
%%
[clu2,res2] = load_clu_res(path2clu2,path2res2,clusters2remove2);
clusters2 = unique(clu2);
nClusters2 = length(clusters2);
spk2 = read_spikes( fname2 ,nchans,template_time_length,clu2,res2);
% spk2 = permute(spk2,[3 2 1]);
[~,nSamples2,nSpikes2] = size(spk2);
score2 = zeros(nchans,N_PC,nSpikes2);

clear cur_spk
for iSpikes2 = 1 : nSpikes2
    cur_spk = spk2(:,:,iSpikes2);
    for iPC = 1 : N_PC
        score2( :,iPC,iSpikes2)=diag(cur_spk * coeff(:,:,iPC)');
    end
    
end
score2=permute(score2,[2 1 3]);
score2 = reshape(score2(:),N_PC * nchans, nSpikes2)';
match_score = zeros(nClusters,nClusters2);
for iClusters1 = 1 : nClusters
    idx = clu == clusters(iClusters1);
    oSpikes = score(idx,:);
    for iClusters2 = 1 : nClusters2
        idx = clu2 == clusters2(iClusters2);
        nSpikes = score2(idx,:);
        d = mahal(nSpikes,oSpikes);
        probs2 = 1 - chi2cdf(d,N_PC * nchans);
        match_score(iClusters1,iClusters2) = geomean(probs2);
    end
    
        
end
fpath1 = fileparts(fname1);
fpath2 = fileparts(fname2);
resOffest = 1;
clusterMethod = 'KS';

% [~,~,ID1] = PCA_analysis...
%     (fpath1,nchans,template_time_length,clusters2remove1,...
%     clusterMethod,resOffest,[]);
% [~,~,ID2] = PCA_analysis...
%     (fpath2,nchans,template_time_length,clusters2remove2,...
%     clusterMethod,resOffest,[]);
figure, imagesc(match_score)
colorbar
tmp_match_score=match_score;
% tmp_match_score(ID1<30,:)=0;
% tmp_match_score(:,ID2<30)=0;
result=nan(nClusters2,1);


while max(tmp_match_score(:))>0.01
    [~,idx]=max(tmp_match_score(:));
    [R,C]=ind2sub(size(tmp_match_score),idx);
    result(C)=R;
    tmp_match_score(R,:)=0;
    tmp_match_score(:,C)=0;
end

