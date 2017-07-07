function [results,com_clusters,clusters1,clusters2] = run_match_clusters_2_frame_back( fpath ,remove_noise_spikes, varargin)

if isempty(varargin)
    max_overlap = 30; %min - maximal overlap between files
    Fs = 20e3; % min - sampling rate
    overlap_step = 10; % min - overlap increase
else
    max_overlap = varargin{1};
    Fs = varargin{2};
    overlap_step = varargin{3};
end
%%
files = dir(fpath);
names = {files.name};
fnames = cellfun(@str2num,names,'UniformOutput',false);
idx = ~cellfun(@isempty,fnames);
files = files(idx);
fnames = cell2mat(cellfun(@str2num,{files.name},'UniformOutput',false));
ordered_names = sort(fnames);
nFolders = length(ordered_names);
clusters2remove = {0,0};
nchans = 8;
template_time_length = 82;
origin = 1;
results = cell(nFolders-1,1);
results2 = cell(nFolders-2,1);
%%
for i = 2 : nFolders
    %% set paths to previous and current folder
    cur_path{1} = fullfile(fpath,sprintf('%d',ordered_names(i-1)));
    cur_path{2} = fullfile(fpath,sprintf('%d',ordered_names(i)));
    
    %% set overlaps used
    if i-1 <= max_overlap / overlap_step
        overlap1 = 0;
    else
        overlap1 = min([(i-2) * overlap_step, overlap_step]);
    end
    overlap2 = min([max_overlap,(i-1) * overlap_step]);

    %% remove noisy spikes
    if remove_noise_spikes
        load(fullfile(cur_path{1}, '\templates.mat'));
        templates2keep{1} = noise_remover(merged_templates);
        nTemplates1 = size(merged_templates,3);
        load(fullfile(cur_path{2},'templates.mat'));
        templates2keep{2} = noise_remover(merged_templates);
        nTemplates2 = size(merged_templates,3);
    else
        templates2keep = cell(2,1);
    end
    [results{i-1}]=match_clusters4( cur_path,clusters2remove,origin,...
        templates2keep,overlap1,overlap2,Fs,1000,0.6);
    if i == 2
        clusters1 = (1:nTemplates1)';        
        prev = 1:nTemplates2;
    else
        prev = clusters1(:,end);
    end
    
    matches = ~isnan(results{i-1}.matches);
    idx = find(matches);
    [~,idx3] = intersect(prev,idx);
    clusters1(idx3,end+1) = results{i-1}.matches(idx);
    
    idx2 = find(~ismember(1:nTemplates2,results{i-1}.matches(idx)));
    tmp = zeros(length(idx2),size(clusters1,2));
    tmp(:,end) = idx2;
    clusters1 = [clusters1; tmp];
    
    if i == 2
        idx2remove1 = ~ismember(clusters1(:,1),templates2keep{1});
        clusters1(idx2remove1,1) = 0;
    end
    idx2remove2 = find(~ismember(1:nTemplates2,templates2keep{2}));
    clusters1(ismember(clusters1(:,end),idx2remove2),end) = 0;
end
for i = 3 : nFolders
    %% set paths to previous and current folder
    cur_path{1} = fullfile(fpath,sprintf('%d',ordered_names(i-2)));
    cur_path{2} = fullfile(fpath,sprintf('%d',ordered_names(i)));
    
    %% set overlaps used
    if i-1 <= max_overlap / overlap_step
        overlap1 = 0;
    else
        overlap1 = min([(i-2) * overlap_step, 2*overlap_step]);
    end
    overlap2 = min(max_overlap-overlap_step,(i-2) * overlap_step);

    %% remove noisy spikes
    if remove_noise_spikes
        load(fullfile(cur_path{1}, '\templates.mat'));
        templates2keep{1} = noise_remover(merged_templates);
        nTemplates1 = size(merged_templates,3);
        load(fullfile(cur_path{2},'templates.mat'));
        templates2keep{2} = noise_remover(merged_templates);
        nTemplates2 = size(merged_templates,3);
    else
        templates2keep = cell(2,1);
    end
    [results2{i-2}]=match_clusters4( cur_path,clusters2remove,origin,...
        templates2keep,overlap1,overlap2,Fs,1000,0.6);
    if i == 3
        clusters2 = (1:nTemplates1)';        
        prev = 1:nTemplates2;
    elseif i==4
        clusters2(end+1:end+nTemplates1,2) = (1:nTemplates1)';        
        prev = clusters2(:,2);
    else
        prev = clusters2(:,end-1);
    end
    
    matches2 = ~isnan(results2{i-2}.matches);
    idx = find(matches2);
    [~,idx3] = intersect(prev,idx);
    if i==3
        clusters2(idx3,end+2) = results2{i-2}.matches(idx);
    else
        clusters2(idx3,end+1) = results2{i-2}.matches(idx);
    end
    idx2 = find(~ismember(1:nTemplates2,results2{i-2}.matches(idx)));
    tmp = zeros(length(idx2),size(clusters2,2));
    tmp(:,end) = idx2;
    clusters2 = [clusters2; tmp];
    
    if i == 3
        idx2remove1 = ~ismember(clusters2(:,1),templates2keep{1});
        clusters2(idx2remove1,1) = 0;
    end
    if i == 4
        idx2remove1 = ~ismember(clusters2(:,2),templates2keep{1});
        clusters2(idx2remove1,2) = 0;
    end
    idx2remove2 = find(~ismember(1:nTemplates2,templates2keep{2}));
    clusters2(ismember(clusters2(:,end),idx2remove2),end) = 0;
end
com_clusters=clusters1;
count=0;
for i = 3 : nFolders
    one_frame_back = com_clusters(:,i-1:i );
    two_frame_back = clusters2(:,i-2:2:i );
    [B1,~]=sortrows(one_frame_back);
    [B2,~]=sortrows(two_frame_back);
    %remove rows with no match
    B1(sum(B1==0,2)>=1,:)=[];
    B2(sum(B2==0,2)>=1,:)=[];
    new_match=setdiff(B2(:,2),B1(:,2));
    new_match=[zeros(numel(new_match),1) , (new_match)];
    for j=1:size(new_match,1)
        new_match(j,1)=B2(B2(:,2)==new_match(j,2),1);
        old_row=(com_clusters(:,i-2)==new_match(j,1));
        new_row=(com_clusters(:,i)==new_match(j,2));
        if sum(com_clusters(old_row,i:end))==0
            com_clusters(old_row,i:end)=com_clusters(new_row,i:end);
            com_clusters(new_row,i:end)=0;
            count=count+1;
        end
    end
        
end
end

