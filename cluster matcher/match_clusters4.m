function result = match_clusters4( fpath,clusters2remove,origin...
    ,templates2keep,varargin)
% match clusters will match templates from two runs of KS. It will do so by
% matching the clu files and detecting clusters with similar spike times.
% overlap is in minutes!!!!!!
match_score = [];
if isempty(varargin)
    % default settings
    overlap1 = 10; % number of minutes to remove from the first file
    overlap2 = 30; % number of minutes to leave in the second file
    Fs = 20e3; % sampling rate in Hz
    min_spikes = 1000; % minimal amount of spikes for a cluster to be concidered
    thresh = 0.7; % threshold for cluster matching
else
    overlap1 = varargin{1};
    overlap2 = varargin{2};
    Fs = varargin{3};
    min_spikes = varargin{4};
    thresh = varargin{5};
end
    

%% constants
N_PC = 3;
normlize_spiks=false;

%% set paths to clu, res and filtered data files
fpath1 = fpath{1};
fpath2 = fpath{2};

files1 = dir(fpath1);
clu_idx = ~cellfun(@isempty,strfind({files1.name},'.clu.2'));
res_idx = ~cellfun(@isempty,strfind({files1.name},'.res.2'));
wh_idx = ~cellfun(@isempty,strfind({files1.name},'temp_wh'));
path2clu1 = fullfile(fpath1,files1(clu_idx).name);
path2res1 = fullfile(fpath1,files1(res_idx).name);
fname1 = fullfile(fpath1,files1(wh_idx).name);

files2 = dir(fpath2);
clu_idx = ~cellfun(@isempty,strfind({files2.name},'.clu.2'));
res_idx = ~cellfun(@isempty,strfind({files2.name},'.res.2'));
wh_idx = ~cellfun(@isempty,strfind({files2.name},'temp_wh'));
path2clu2 = fullfile(fpath2,files2(clu_idx).name);
path2res2 = fullfile(fpath2,files2(res_idx).name);
fname2 = fullfile(fpath2,files2(wh_idx).name);


%% set ground truth (1 -> 2 or 2 -> 1)
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
%% read clu files
[clu1,res1] = load_clu_res (path2clu1, path2res1 , clusters2remove1);
clusters1 = 1 : max(clu1);
nClusters1 = max(clusters1);
[clu2,res2] = load_clu_res(path2clu2,path2res2,clusters2remove2);
clusters2 = 1: max(clu2);
nClusters2 = max(clusters2);
%% remove noisy clusters
if sum(~cellfun(@isempty,templates2keep)) > 0
    idx2remove1 = ~ismember(clu1,templates2keep{1});
    idx2remove2 = ~ismember(clu2,templates2keep{2});
    clu1(idx2remove1) = [];
    res1(idx2remove1) = [];
    res2(idx2remove2) = [];
    clu2(idx2remove2) = [];
    
end

% Removing the second spike if two spikes occured at once
idx2remove1 = ~diff(res1);
idx2remove2 = ~diff(res2);
idx2remove1 = [false; idx2remove1];
idx2remove2 = [false; idx2remove2];

res1(idx2remove1) = [];
clu1(idx2remove1) = [];
res2(idx2remove2) = [];
clu2(idx2remove2) = [];

%  Removing spikes occuring one sample after the other
idx2remove1 = diff(res1) == 1;
idx2remove2 = diff(res2) == 1;
idx2remove1 = [false; idx2remove1];
idx2remove2 = [false; idx2remove2];
res1(idx2remove1) = [];
clu1(idx2remove1) = [];
res2(idx2remove2) = [];
clu2(idx2remove2) = [];

%% create cropped clu & res
%remove first overlap minutes of the first clu%res and recentering the res
%file
keep_idx1 = (res1-Fs*overlap1*60)>0;
res1hat=res1(keep_idx1)-Fs*overlap1*60+1;
clu1hat=clu1(keep_idx1);
%remove last overlap minutes of the second clu%res
keep_idx2 = (res2 - Fs*overlap2 * 60) < 0;
res2hat=res2( keep_idx2);
clu2hat=clu2(keep_idx2);
%creat a combined clu  - first col is the clu from first clu file, second col is
%the clu from second clu file2
% clu_matcher=clu1hat;
% clu_matcher(:,2)=0;

%% match clus
% for i= 1:length(clu1hat)
%     for offs=-1:1
%         if max(ismember(res1hat(i)+offs,res2hat))==1
%             tmp=clu2hat(res2hat==res1hat(i)+offs);
%             clu_matcher(i,2)=tmp(1);
%         end
%     end
% end
clu_matcher = [];
for offs = -1 : 1
    tmp_res = res2hat + offs;
    idx1 = ismember(res1hat,tmp_res);
    idx2 = ismember(tmp_res,res1hat);
    clu_matcher = [clu_matcher; [clu1hat(idx1) clu2hat(idx2)]];
end
%count rows in clu_matcher to creat match_score
match_score=zeros(nClusters1,nClusters2);
for iClusters1 = 1 : nClusters1
    for iClusters2 = 1 : nClusters2
        match_score(iClusters1,iClusters2)=sum(and(clu_matcher(:,1)==iClusters1,...
            clu_matcher(:,2)==iClusters2));
    end    
end
S = sum(match_score,2);
n_match_score = bsxfun(@rdivide,match_score,S); % normalized match_score

result.match_score = match_score;
result.n_match_score = n_match_score;

%% create matching index
result.matches=nan(nClusters1,1);
n_match_score(S < min_spikes, : ) = -inf;


while max(n_match_score(:)) > thresh
    [~,idx1]=max(n_match_score(:));
    [R,C]=ind2sub(size(n_match_score),idx1);
    result.matches(R)=C;
    n_match_score(R,:)=-inf;
    n_match_score(:,C)=-inf;
%     figure, imagesc(n_match_score); colorbar
%     pause(3);
end

result.min_spikes = min_spikes;
result.threshold = thresh;
return









% match_score = 1 - match_score;
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
% tmp_match_score=match_score;
%% D threshold part 2/2
% tmp_match_score(ID1<30,:)=0;
% tmp_match_score(:,ID2<30)=0;
%% N threshold
% tmp_match_score(N1<1e3,:)=inf;
% tmp_match_score(:,N2<1e3)=inf;
%% matcher monogamy mathcing with threshold of 0.06 sholed replace threshold with 
% https://en.wikipedia.org/wiki/Welch%27s_t-test and a more intuitive score
% result=nan(nClusters2,1);
% I removed the N threshold for now. Not sure what it is, we should
% discuss. Also, I set the threshold to 0.8 (meaning htat we have a match
% of above 0.2 (1-0.2). I don't know if this is too high. We should
% discuss
% while min(tmp_match_score(:))< 0.8
%     [~,idx]=min(tmp_match_score(:));
%     [R,C]=ind2sub(size(tmp_match_score),idx);
%     result(C)=R;
%     tmp_match_score(R,:)=inf;
%     tmp_match_score(:,C)=inf;
% %     figure, imagesc(tmp_match_score);
% end
% return