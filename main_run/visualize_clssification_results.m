function visualize_clssification_results( results,path2figures )
%get cell arreay of results struct created by compare_OLM_RTS
allThresh = linspace(0,80,11);
con_results=[];
for i=1:length(results)
    con_results=[con_results results{i}];
end
M=0;
for i=1:length (con_results)
    M=(M+ length (con_results(i).sensitivity_calssification));
end
N_files=length(con_results);

num_neurons = []; 
sensitivity_calssification = nan(length(allThresh),M);
precision_calssification = nan(length(allThresh),M);
ID = [];
sensitivity_calssification_rmoved_inherent=nan(length(allThresh),M);
precision_calssification_rmoved_inherent=nan(length(allThresh),M);
for n = 1 : length(allThresh)
    cur_neurons = []; 
    cur_sensitivity_calssification = [];
    cur_precision_calssification = [];
    cur_ID = [];
    cur_sensitivity_calssification_rmoved_inherent=[];
    cur_precision_calssification_rmoved_inherent=[];
    tmp_results = con_results;
    for m = 1 : N_files
        nan_idx = tmp_results(m).I_dis < allThresh(n);
        tmp_results(m).sensitivity_calssification(nan_idx) = nan;
        tmp_results(m).precision_calssification (nan_idx) = nan;
        tmp_results(m).I_dis(nan_idx) = nan;
        tmp_results(m).sensitivity_calssification_rmoved_inherent(nan_idx) = nan;
        tmp_results(m).precision_calssification_rmoved_inherent(nan_idx) = nan;

        cur_sensitivity_calssification = cat(1,cur_sensitivity_calssification,...
            (tmp_results(m).sensitivity_calssification(:)));
        cur_precision_calssification = cat(1,cur_precision_calssification,...
            (tmp_results(m).precision_calssification(:)));
        cur_neurons = cat(1,cur_neurons,sum(~isnan(tmp_results(m).sensitivity_calssification)));
        cur_ID = cat(1,cur_ID,tmp_results(m).I_dis(:));
        cur_sensitivity_calssification_rmoved_inherent = cat(1,cur_sensitivity_calssification_rmoved_inherent,...
            (tmp_results(m).sensitivity_calssification_rmoved_inherent(:)));
        cur_precision_calssification_rmoved_inherent = cat(1,cur_precision_calssification_rmoved_inherent,...
            (tmp_results(m).precision_calssification_rmoved_inherent(:)));
    end
    sensitivity_calssification(n,1:length(cur_sensitivity_calssification)) = ...
        cur_sensitivity_calssification;
    precision_calssification(n,1:length(cur_precision_calssification)) = ...
        cur_precision_calssification;
    num_neurons = cat(2,num_neurons,cur_neurons);
    ID = cat(2,ID,cur_ID);
    sensitivity_calssification_rmoved_inherent(n,1:length(cur_sensitivity_calssification_rmoved_inherent)) = ...
        cur_sensitivity_calssification_rmoved_inherent;
    precision_calssification_rmoved_inherent(n,1:length(cur_precision_calssification_rmoved_inherent)) = ...
        cur_precision_calssification_rmoved_inherent;

end

h = figure;
subplot(3,2,1);
boxplot(1e2*sensitivity_calssification');
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
% xlabel('Isolation Distance threshold');
ylabel('Sensitivity [%]','FontSize',14);
ylim ([0 100]);
title('With Inherent Error','FontSize',16)
grid on


subplot(3,2,3);
boxplot(1e2*precision_calssification')
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
% xlabel('Isolation Distance threshold');
ylabel('Precision [%]','FontSize',14)
ylim ([0 100]);
title('With Inherent Error','FontSize',16)
grid on

subplot(3,2,2);
boxplot(1e2*sensitivity_calssification_rmoved_inherent');
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
% xlabel('Isolation Distance threshold')
ylim ([0 100]);
title('Exclude Inherent Error','FontSize',16)
grid on

subplot(3,2,4);
boxplot(1e2*precision_calssification_rmoved_inherent')
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
% xlabel('Isolation Distance threshold','FontSize',14)
ylim ([0 100]);
title('Exclude Inherent Error','FontSize',16)
grid on

if size(num_neurons,1)==1
    num_neurons(2,:)=nan;
end

subplot(3,2,5)
boxplot(num_neurons)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
title('Number of Neurons as a function of Isolation Distance','FontSize',16);
xlabel('Isolation Distance Threshold','FontSize',14), ylabel('# Neurons','FontSize',14)
grid on

subplot(3,2,6)
boxplot(ID)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
title('Isolation Distance of Remaining Neurons','FontSize',16);
xlabel('Isolation Distance Threshold','FontSize',14);
ylabel('Iolation Distance','FontSize',14)
grid on

set(gcf, 'Position', get(0, 'Screensize'));

savefig(h,fullfile(path2figures,'TPR-FPR - test'));
saveas(h,fullfile(path2figures,'TPR-FPR - test.png'));

nDays = length(results);
data = nan(nDays,3);
eData = nan(nDays,3);
%% statistics
for day = 1 : nDays
    raw_data = [[results{day}.AI_N_spikes_coorect]./[results{day}.N_spiks_before_inherent];...
     [results{day}.AI_N_spikes_incoorect]./[results{day}.N_spiks_before_inherent];...  
      [results{day}.N_inherent_spikes]./[results{day}.N_spiks_before_inherent]]   ;

     data(day,:) = 1e2*mean(raw_data,2);
    eData(day,:) = 1e2*std(raw_data,0,2);
end
if nDays==1
    data(2,:)=nan;
    eData(2,:)=nan;
end
%% plot 
% Properties of the bar graph as required
handle = figure;
ax = axes;
h = bar(data,'stacked','BarWidth',1);
ax.YGrid = 'on';
ax.GridLineStyle = '-';

% Naming each of the bar groups
% set(ax,'XTick',1:nDays);
% % xticks(ax,1 : nDays);
% for day = 1 : nDays
%     labels{day} = sprintf('Day %d',day);
% end
% set(ax,'XTickLabels',labels);
% xticklabels(ax,labels);

% X and Y labels
ylabel('Detection [%]');
% xlabel('Days');

% Creating a legend and placing it outside the bar plot
lg = legend({'True Classification','False Classification','Inherent Mistake'},'FontSize',14);
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';
ylim ([0 110]);

% if nDays==1
%     xlim ([0 2]);
%     set(ax,'XTickLabel','Training Set');
% end
hold on;
set(ax,'XTickLabel',{'Training Set','Test Set'},'FontSize',14);

% Finding the number of groups and the number of bars in each group
[ngroups,nbars] = size(data);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));

x = 1 : ngroups;
aa=-0.25:0.25:0.25;
% Set the position of each error bar in the centre of the main bar
for i = 1 : nbars
    errorbar(x+aa(i),sum(cat(1,h(1:i).YData),1),eData(:,i),'k','linestyle','none');
end
set(gcf, 'Position', get(0, 'Screensize'));

% savefig(handle,fullfile(path2figures,'Classification Error'));
% saveas(handle,fullfile(path2figures,'Classification Error.png'));

end

