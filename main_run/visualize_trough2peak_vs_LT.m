function visualize_trough2peak_vs_LT ( fpaths,Fs,path2figures,varargin )

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
% ID = cat(1,varargin{1}{1}.I_dis);
train_ID = varargin{1}{1}(1).I_dis;
test_ID = varargin{1}{1}(2).I_dis;
train_ID ( train_ID > 60 ) = 60;
test_ID ( test_ID > 60 ) = 60;

LT = cat(1,LT{:});
% LT = cat(1,LT{:});
train_LT = LT{1};
test_LT = LT{2};
train_LT = train_LT - 1;
test_LT = test_LT - 1;
train_t2p = t2p{1}(1:length(train_LT));
test_t2p = t2p{1}(length(train_LT)+1 : end);

% idx2remove = LT == 0;
% LT(idx2remove) = [];
% t2p(idx2remove) = [];
% ID(idx2remove) = [];
figure;
h = correlate_LT ( train_LT, train_t2p, train_ID,1,Fs )
h = correlate_LT ( test_LT, test_t2p, test_ID,3,Fs,'r' )

a = zeros(length(train_LT),1);
a (train_LT > 3) = 1;
[X,Y] = perfcurve(a,train_ID,1);
figure, plot(X,Y,'b'), hold on;
a = zeros(length(test_LT),1);
a(test_LT > 3) = 1;
[X2,Y2] = perfcurve(a,test_ID,1);
plot(X2,Y2,'r');
lg = legend('Training Set','Testing Set','Location','Bestoutside','Orientation','Horizontal');
lg.FontSize = 11;
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title('Isolation distance ROC');

savefig(h,fullfile(path2figures,'Trough to Peak results'));
saveas(h,fullfile(path2figures,'Trough to Peak results.png'));


return
function h = correlate_LT ( LT, t2p, ID,k,Fs,varargin )
if isempty(varargin)
    varargin{1} = 'b';
end
[RHO_t2p,PVAL_t2p] = corr(t2p/Fs * 1e3,LT/ Fs * 1e3 /60,'type','spearman');
[RHO,PVAL] = corr(ID,LT/ Fs * 1e3 /60,'type','spearman');

LT = LT + 0.15*randn(length(LT),1);
t2p = t2p + 0.15*randn(length(t2p),1);

h = gcf;
subplot(2,2,k);
scatter(t2p/Fs * 1e3,LT * 10,15,varargin{1},'Filled');
text(0.5,0.9,sprintf('r = %2.2f \np = %1.1e ',RHO_t2p,PVAL_t2p),'Units','Normalized','FontSize',12);
if k > 1
    xlabel('Trough to Peak [msec]');
end
if k == 1
    title('Training Set');
else
    title('Testing Set');
end
ylabel('Life Time [min]');
% lsline
xlim([0 2]);
ylim([0 300]);
% h = figure; 
subplot(2,2,k+1);
scatter(ID,LT * 10 ,15,varargin{1},'Filled');
text(0.5,0.9,sprintf('r = %2.2f \np = %1.1e ',RHO,PVAL),'Units','Normalized','FontSize',12);
if k > 1
    xlabel('Isolation Distance');
end
if k == 1
    title('Training Set');
else
    title('Testing Set');
end
% lsline;
ylim([0 300]);
labels = get(gca,'XTickLabel'); labels{end} = strcat(labels{end},'+');
set(gca,'XTickLabel',labels);




