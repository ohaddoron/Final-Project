function visualize_trough2peak_vs_LT ( fpaths,Fs,path2figures )

%% init
nDays = length( fpaths ) ;
LT = cell(nDays,1);
t2p = cell(nDays,1);
%%
for i = 1 : nDays
    fpath = fpaths{i};
    [templates,LT{i}] = gather_templates_LT ( fpath );
    t2p{i} = trough2peak(templates);
end

LT = cat(1,LT{:});
t2p = cat(1,t2p{:});
idx2remove = LT == 1;
LT(idx2remove) = [];
t2p(idx2remove) = [];

LT = LT + 0.3*randn(length(LT),1);
t2p = t2p + 0.3*randn(length(t2p),1);

h = figure; 
scatter(t2p/Fs * 1e3,LT,15,'Filled');
xlabel('Trough to Peak [msec]');
ylabel('Life Time');
lsline;
savefig(h,fullfile(path2figures,'Trough to Peak results'));
saveas(h,fullfile(path2figures,'Trough to Peak results.png'));


return

