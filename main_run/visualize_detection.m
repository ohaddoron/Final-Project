function visualize_detection ( detection_results,path2figures )

%% init
flag = false;
nDays = length(detection_results);
data = nan(nDays,7);
eData = nan(nDays,7);
%% statistics
for day = 1 : nDays
    raw_data = detection_results{day};
    data(day,:) = 100 * mean(raw_data,2);
    if size(raw_data,2) == 1
        eData(day,:) = nan;
        flag = true;
    else
        eData(day,:) = 100 * std(raw_data,0,2);
    end
end
if nDays == 1
    data = [data; nan(1,length(data))];
    eData = [eData; nan(1,length(data))];
end


%% plot 
% Properties of the bar graph as required
h = figure;
ax = axes;
b = bar(data,'stacked','BarWidth',1);
ax.YGrid = 'on';
ax.GridLineStyle = '-';
if nDays == 1
    xlim([0, 2]);
end
% Naming each of the bar groups
% xticks(ax,1 : nDays);
ax.XTick = 1 : nDays;
if flag
    labels = {'Training Set','Test Set'}
else
    for day = 1 : nDays
        labels{day} = sprintf('Day %d',day);
    end
end
set(ax,'XTickLabels',labels,'FontSize',14);


% X and Y labels
ylabel('Detection [%]','FontSize',14);
if ~flag
    xlabel('Days','FontSize',14);
end

% Creating a legend and placing it outside the bar plot
lg = legend({'KS&OLM&RTS','KS&OLM&~RTS','KS&RTS&~OLM','KS&~RTS&~OLM'...
    ,'only OLM','(OLM | RTS) - KS','only RTS'},'FontSize',12);
lg.Location = 'BestOutside';
lg.Orientation = 'Horizontal';
set(gcf, 'Position', get(0, 'Screensize'));


hold on;

% Finding the number of groups and the number of bars in each group
[ngroups,nbars] = size(data);

% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));

x = 1 : ngroups;
% Set the position of each error bar in the centre of the main bar
for i = 1 : nbars
    errorbar(x,sum(cat(1,b(1:i).YData),1),eData(:,i),'k','linestyle','none');
end
savefig(h,fullfile(path2figures,'Detection results'));
saveas(h,fullfile(path2figures,'Detection results.png'));
return

