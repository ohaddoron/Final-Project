% clear all; close all; clc;
%% get input
path2results = get_data;
%% run kilosort
run_kilosort (path2results);
%% run test score
thresh = 0;
mean_hits = zeros(length(path2results),1);
std_hits = zeros(length(path2results),1);
mean_FP = zeros(length(path2results),1);
std_FP = zeros(length(path2results),1);
num_neurons = zeros(length(path2results),1);
for i = 1 : length(path2results)
    results(i) = test_score(path2results{i},thresh);
    mean_hits(i) = nanmean(results(i).hits);
    std_hits(i) = nanstd(results(i).hits);
    mean_FP(i) = nanmean(results(i).FP);
    std_FP(i) = nanstd(results(i).FP);
    num_neurons(i) = sum(~isnan(results(i).hits));
end
% figure, hold on, bar(1:length(mean_hits),mean_hits)
% errorbar(1:length(mean_hits),mean_hits,std_hits,'.k');
% figure, hold on, bar(1:length(mean_FP),mean_FP)
% errorbar(1:length(mean_FP),mean_FP,std_FP,'.k');
save(fullfile('D:\matlab\Results','Correlation Results.mat'),'results');
%% calc f_half
% f_half = nan(length(path2results),4); 
% miss1 = nan(length(path2results),1);
% miss2 = nan(length(path2results),1);
% hits = cell(length(path2results),1);
% for i = 1 : length(path2results)
%     path1 = path2results{i};
%     path2 = path1;
%     datfile = dir(fullfile(path2results{i},'*.dat'));
%     datfile = datfile(1);
%     res1name = strrep(datfile.name,'dat','res.1');
%     res2name = strrep(datfile.name,'dat','res.2');
%     clu1name = strrep(datfile.name,'dat','clu.1');
%     clu2name = strrep(datfile.name,'dat','clu.2');
%     
%     samples_offset = 2;
%     
%     [f_half(i,:),miss1(i),miss2(i), hits{i}] = calc_f_half ( path1 , path2 , res1name, res2name, ...
%         clu1name, clu2name, samples_offset );
% end
