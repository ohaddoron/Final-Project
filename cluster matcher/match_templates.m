function [dist,idx,dis_mat,dist_CC,idx_CC,CC] = match_templates(oTemplates,nTemplates)
% The function will match matrices from the previous run of KS and the new
% run. It will return an index correlating the old and the new and also the
% distance between each of the templates
% It does not matter which of the templates is longer
nNew = size(nTemplates,3);
nOld = size(oTemplates,3);
idx = zeros(max([nOld,nNew]),2);
idx_CC = zeros(max([nOld,nNew]),2);
dist = zeros(max([nOld,nNew]),1);
dis_mat = zeros(nOld,nNew);
CC = zeros(nOld,nNew);
%% 2D distance
    %% cycle through old templates
    for i = 1 : nOld
        d = zeros(nNew,1);
        cur_oTemplate = oTemplates(:,:,i);
        %% cycle through new templates
        for k = 1 : nNew
            cur_nTemplate = nTemplates(:,:,k);
            dist_mat = cur_oTemplate - cur_nTemplate;
            d(k) = sqrt(trace(dist_mat * dist_mat'));
            dis_mat(i,k) = d(k);
        end
        [dist(i),idx(i,2)] = min(d);
        idx(i,1) = i;
    %     figure, subplot(211), plot(cur_oTemplate')
    %     subplot(212), plot(nTemplates(:,:,idx(i,2))');
    end
%% Correlation
    for i = 1 : nOld
        CC_tmp = zeros(nNew,1);
        cur_oTemplate = oTemplates(:,:,i);
        %% cycle through new templates
        for k = 1 : nNew
            cur_nTemplate = nTemplates(:,:,k);
            CC_tmp(k) = sum(cur_oTemplate(:).*cur_nTemplate(:));
            CC(i,k) = CC_tmp(k);
        end
        [dist_CC(i),idx_CC(i,2)] = max(CC_tmp);
        idx_CC(i,1) = i;
    %     figure, subplot(211), plot(cur_oTemplate')
    %     subplot(212), plot(nTemplates(:,:,idx(i,2))');
    end

return

        
        
        
    
