function visualize_LT ( fpaths,overlap_time )

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
h1 = histogram(LT * overlap_time,100);
set(h1,'Normalization','probability','EdgeAlpha',0.1)
xlabel('Life Time [min]','FontSize',14);
ylabel('Fraction of Cells','FontSize',14);
title('Distribution of Life Times','FontSize',16);

return