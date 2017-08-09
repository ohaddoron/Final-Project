function visualize_f_half ( comparison_results )

%% init
nDays = length(comparison_results);
data = nan(nDays,3);
eData = nan(nDays,3);
labels = cell(nDays,1);
%% statistics
for day = 1 : nDays 
    results = comparison_resutls{day};
    data(day,1) = nanmean(cat(1,results.f_half_KS_OLM));
    data(day,2) = nanmean(cat(1,results.f_half_KS_RTS));
    data(day,3) = nanmean(cat(1,results.f_half_OLM_RTS));
    eData(day,1) = nanstd(cat(1,results.f_half_KS_OLM));
    eData(day,2) = nanstd(cat(1,results.f_half_KS_RTS));
    eData(day,3) = nanstd(cat(1,results.f_half_OLM_RTS));
end
%% plot

% Properties of the bar graph as required
ax = axes;
h = bar(data,'BarWidth',1);
ax.YGrid = 'on';
ax.GridLineStyle = '-';

% Naming each of the bar groups
xticks(ax,1 : nDays);
for day = 1 : nDays
    labels{day} = sprintf('Day %d',day);
end
xticklabels(ax,labels);

% X and Y labels
ylabel('f_{1/2}');
xlabel('Days');

% Creating a legend and placing it outside the bar plot
lg = legend({'KS vs OLM','KS vs RTS','OLM vs RTS'},'autoupdate','off');
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



