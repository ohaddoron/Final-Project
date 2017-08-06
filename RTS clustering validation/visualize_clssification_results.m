function [  ] = visualize_clssification_results( results )
%get cell arreay of results struct created by compare_OLM_RTS
allThresh = linspace(0,80,11);
N_files=size(results);

neurons = []; 
sensitivity_calssification = [];
precision_calssification = [];
ID = [];
sensitivity_calssification_rmoved_inherent=[];
precision_calssification_rmoved_inherent=[];
for n = 1 : size(allThresh)
    cur_neurons = []; 
    cur_sensitivity_calssification = [];
    cur_precision_calssification = [];
    cur_ID = [];
    cur_sensitivity_calssification_rmoved_inherent=[];
    cur_precision_calssification_rmoved_inherent=[];
    tmp_results = results;
    for m = 1 : N_files
        nan_idx = results(m).ID_OLM < allThresh(n);
        tmp_results(m).sensitivity_calssification(nan_idx) = nan;
        tmp_results(m).precision_calssification (nan_idx) = nan;
        tmp_results(m).ID_OLM(nan_idx) = nan;
        tmp_results(m).sensitivity_calssification_rmoved_inherent(nan_idx) = nan;
        tmp_results(m).precision_calssification_rmoved_inherent(nan_idx) = nan;

        cur_sensitivity_calssification = cat(1,cur_sensitivity_calssification,...
            (tmp_results(m).sensitivity_calssification(:)));
        cur_precision_calssification = cat(1,cur_precision_calssification,...
            (tmp_results(m).precision_calssification(:)));
        cur_neurons = cat(1,cur_neurons,sum(~isnan(tmp_results(m).sensitivity_calssification)));
        cur_ID = cat(1,cur_ID,tmp_results(m).ID_OLM(:));
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
figure;
subplot(3,2,1);
boxplot(sensitivity_calssification);
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('hits [%]')

subplot(3,2,2);
boxplot(precision_calssification)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('FP [%]')

subplot(3,2,3);
boxplot(sensitivity_calssification_rmoved_inherent);
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('hits [%]')

subplot(3,2,4);
boxplot(precision_calssification_rmoved_inherent)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('FP [%]')

subplot(3,2,5)
boxplot(num_neurons)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('num neurons')

subplot(3,2,6)
boxplot(ID)
set(gca,'XTickLabel',round(allThresh,1),'XTickLabelRotation',90);
xlabel('Isolation Distance threshold'), ylabel('ID')




    
    
end

