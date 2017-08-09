function visualize_detection ( detection_results )

%% init 
nDays = length(detection_results);
data = nan(nDays,7);
eData = nan(nDays,7);
%% statistics
for day = 1 : nDays
    raw_data = detection_results{day};
    data(day,:) = mean(raw_data,2);
    eData(day,:) = std(raw_data,0,2);
end

%% plot 
% Properties of the bar graph as required
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
lg = legend({'KS&OLM&RTS','KS&OLM&~RTS','KS&RTS&~OLM','KS&~RTS&~OLM'...
    ,'only OLM','(OLM | RTS) - KS','only RTS'},'autoupdate','off','FontSize',14);
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