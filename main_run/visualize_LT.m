function visualize_LT ( fpaths,overlap_time,path2figures )

%% init
nDays = length(fpaths);
LT = cell(nDays,1);
%% calculate life time
for i = 1 : nDays 
    fpath = fpaths{i};
    [~,LT{i}] = gather_templates_LT ( fpath );
end
LT = cat(1,LT{:});

%% plot

h = figure; 
handle1 = subplot(211);
h1 = histogram(LT{1} * overlap_time,25);
set(h1,'EdgeAlpha',0.1)
legend({'Training Set'},'FontSize',14);
handle2 = subplot(212);
h2 = histogram(LT{2} * overlap_time,25);
legend({'Testing Set'},'FontSize',14);
set(h2,'EdgeAlpha',0.1,'FaceColor','r')
xlabel('Life Time [min]','FontSize',14);
p1=get(handle1,'position');
p2=get(handle2,'position');
height=p1(2)+p1(4)-p2(2);
h3=axes('position',[p2(1) p2(2) p2(3) height],'visible','off');
h_label=ylabel('Fraction of Cells','visible','on','FontSize',14);
title('Distribution of Life Times','FontSize',16);
set(gcf, 'Position', get(0, 'Screensize'));
savefig(h,fullfile(path2figures,'Life Time'));
saveas(h,fullfile(path2figures,'Life Time.png'));
return