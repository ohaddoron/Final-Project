allThresh = linspace(0,80,11);
% R = cell(10,1);
% for n = 1 
%     fprintf('Current session: %i\n', n);
%     thresh = allThresh(n);
%     main;
%     R{n} = results;
% end

hits = [];
FP = [];
num_neurons = [];
ID = [];
load('D:\matlab\Results\Correlation Results.mat')
for n = 1 : 11
    cur_neurons = []; 
    cur_hits = [];
    cur_FP = [];
    cur_ID = [];
    tmp_results = results;
    for m = 1 : 12
        nan_idx = results(m).I_dis < allThresh(n);
        tmp_results(m).hits(nan_idx) = nan;
        tmp_results(m).FP(nan_idx) = nan;
        tmp_results(m).I_dis(nan_idx) = nan;
        
        
        cur_hits = cat(1,cur_hits,(tmp_results(m).hits(:)));
        cur_FP = cat(1,cur_FP,(tmp_results(m).FP(:)));
        cur_neurons = cat(1,cur_neurons,sum(~isnan(tmp_results(m).hits)));
        cur_ID = cat(1,cur_ID,tmp_results(m).I_dis(:));
    end
    hits = cat(2,hits,cur_hits);
    FP = cat(2,FP,cur_FP);
    num_neurons = cat(2,num_neurons,cur_neurons);
    ID = cat(2,ID,cur_ID);
end
figure;
subplot(2,2,1);
boxplot(hits);
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('hits [%]')
subplot(2,2,2);
boxplot(FP)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('FP [%]')
subplot(2,2,3)
boxplot(num_neurons)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('num neurons')

subplot(2,2,4)
boxplot(ID)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('ID')



    
    