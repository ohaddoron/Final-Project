function visualize_f_half ( comparison_results,path2figures )

%% init
nDays = length(comparison_results);
data = nan(nDays,3);
eData = nan(nDays,3);
labels = cell(nDays,1);
%% statistics
for day = 1 : nDays 
    
    results = comparison_results{day};
    if size(results.f_half_KS_OLM,1) == 1
        flag = true;
    end
    tmp = nanmean(cat(1,results.f_half_KS_OLM),1);
    data(day,1) = tmp(end);
    tmp = nanmean(cat(1,results.f_half_KS_RTS),1);
    data(day,2) = tmp(end);
    tmp = nanmean(cat(1,results.f_half_OLM_RTS),1);
    data(day,3) = tmp(end);
    tmp = nanstd(cat(1,results.f_half_KS_OLM),0,1);
    eData(day,1) = tmp(end);
    tmp = nanstd(cat(1,results.f_half_KS_RTS),0,1);
    eData(day,2) = tmp(end);
    tmp = nanstd(cat(1,results.f_half_OLM_RTS),0,1);
    eData(day,3) = tmp(end);
end
%% plot
if flag 
    eData = nan(size(eData));
end
% Properties of the bar graph as required
if nDays == 1
    data = [data; nan(1,length(data))];
    eData =[eData; nan(1,length(eData))];
end
h = figure;
ax = axes;
b = bar(data,'BarWidth',1);
ax.YGrid = 'on';
ax.GridLineStyle = '-';
% if nDays == 1
%     xlim([0 2]);
% end
% Naming each of the bar groups
ax.XTick = 1 : nDays;
if flag 
    labels = {'Training Set','Test Set'};
else
    for day = 1 : nDays
        labels{day} = sprintf('Day %d',day);
    end
end
set(ax,'XTickLabel',labels,'FontSize',14);

% X and Y labels
ylabel('f_{1/2}','FontSize',14);
if ~flag
    xlabel('Days','FontSize',14);
end

% Creating a legend and placing it outside the bar plot
lg = legend({'KS vs OLM','KS vs RTS','OLM vs RTS'},'FontSize',12);
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';

hold on;

% Finding the number of groups and the number of bars in each group
[ngroups,nbars] = size(data);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));



% Set the position of each error bar in the centre of the main bar
for i = 1 : nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x,data(:,i),eData(:,i),'k','linestyle','none');
end
set(gcf, 'Position', get(0, 'Screensize'));

savefig(h,fullfile(path2figures,'f half results'));
saveas(h,fullfile(path2figures,'f half results.png'));
return


