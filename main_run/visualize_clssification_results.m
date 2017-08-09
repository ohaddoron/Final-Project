function visualize_clssification_results( results,path2figures )
%get cell arreay of results struct created by compare_OLM_RTS
allThresh = linspace(0,80,11);
con_results=[];
for i=1:length(results)
    con_results=[con_results results{i}];
end
N_files=length(con_results);

num_neurons = []; 
sensitivity_calssification = [];
precision_calssification = [];
ID = [];
sensitivity_calssification_rmoved_inherent=[];
precision_calssification_rmoved_inherent=[];
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
    sensitivity_calssification = cat(2,sensitivity_calssification,...
        cur_sensitivity_calssification);
    precision_calssification = cat(2,precision_calssification,...
        cur_precision_calssification);
    num_neurons = cat(2,num_neurons,cur_neurons);
    ID = cat(2,ID,cur_ID);
    sensitivity_calssification_rmoved_inherent = cat(2,sensitivity_calssification_rmoved_inherent...
         ,cur_sensitivity_calssification_rmoved_inherent);
    precision_calssification_rmoved_inherent = cat(2,precision_calssification_rmoved_inherent,...
        cur_precision_calssification_rmoved_inherent);
    
end
h = figure;
subplot(3,2,1);
boxplot(1e2*sensitivity_calssification);
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('Sensitivity [%]')
ylim ([0 100]);

subplot(3,2,2);
boxplot(1e2*precision_calssification)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('Precision [%]')
ylim ([0 100]);

subplot(3,2,3);
boxplot(1e2*sensitivity_calssification_rmoved_inherent);
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('Sensitivity [%]')
ylim ([0 100]);

subplot(3,2,4);
boxplot(1e2*precision_calssification_rmoved_inherent)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('Precision [%]')
ylim ([0 100]);

subplot(3,2,5)
boxplot(num_neurons)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('num neurons')

subplot(3,2,6)
boxplot(ID)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('ID')

savefig(h,fullfile(path2figures,'TPR-FPR'));
saveas(h,fullfile(path2figures,'TPR-FPR.png'));

nDays = length(results);
data = nan(nDays,3);
eData = nan(nDays,3);
%% statistics
for day = 1 : nDays
    raw_data = [[results{day}.AI_N_spikes_coorect]./[results{day}.N_spiks_before_inherent];...
     [results{day}.AI_N_spikes_incoorect]./[results{day}.N_spiks_before_inherent];...  
      [results{day}.N_inherent_spikes]./[results{day}.N_spiks_before_inherent]]   ;

     data(day,:) = mean(raw_data,2);
    eData(day,:) = std(raw_data,0,2);
end

%% plot 
% Properties of the bar graph as required
h = figure;
ax = axes;
h = bar(data,'stacked','BarWidth',1);
ax.YGrid = 'on';
ax.GridLineStyle = '-';

% Naming each of the bar groups
xticks(ax,1 : nDays);
for day = 1 : nDays
    labels{day} = sprintf('Day %d',day);
end
xticklabels(ax,labels);

% X and Y labels
ylabel('Detection [%]');
xlabel('Days');

% Creating a legend and placing it outside the bar plot
lg = legend({'corect classification','wrong classification','inharent mistake'}...
    ,'autoupdate','off','FontSize',14);
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';


hold on;

% Finding the number of groups and the number of bars in each group
[ngroups,nbars] = size(data);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));

x = 1 : ngroups;
% Set the position of each error bar in the centre of the main bar
for i = 1 : nbars
    errorbar(x,sum(cat(1,h(1:i).YData),1),eData(:,i),'k','linestyle','none');
end
savefig(h,fullfile(path2figures,'Classification Error'));
saveas(h,fullfile(path2figures,'Classification Error.png'));

end

