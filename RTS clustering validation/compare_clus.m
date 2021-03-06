function [ sensitivity_calssification,precision_classification ] =...
    compare_clus( OLM_clu ,RTS_clu,N_clusters)
%% compare complete OLM to complete RTS
n_clusters_OLM = N_clusters;
nSpikes_OLM = zeros(1,n_clusters_OLM);
%count OLM spikes
for i = 1 : n_clusters_OLM
    nSpikes_OLM(i) = sum(OLM_clu == i);
end
%count RTS spiks
n_clusters_RTS = N_clusters;
nSpikes_RTS = zeros(1,n_clusters_RTS);
for i = 1 : n_clusters_RTS
    nSpikes_RTS(i) = sum(RTS_clu == i);
end

sensitivity_calssification = nan(n_clusters_OLM,1);
precision_classification = nan(n_clusters_OLM,1);
for i = 1 : n_clusters_OLM
    
    tmp_clu_OLM = OLM_clu;
    tmp_clu_OLM(OLM_clu ~= i) = nan;
    
    tmp_clu_RTS = RTS_clu;
    tmp_clu_RTS(RTS_clu ~= i) = nan;
    
    if isempty(tmp_clu_RTS)
        continue
    end
    sensitivity_calssification(i) = nansum((tmp_clu_OLM - tmp_clu_RTS) == 0) / nSpikes_OLM(i);
    tmp = OLM_clu - tmp_clu_RTS;
    tmp(isnan(tmp)) = [];
    if i <= n_clusters_RTS
        precision_classification(i) = 1  -  nansum(tmp ~= 0) / nSpikes_RTS(i);
    else
        precision_classification(i) = 0;
    end
    
end

end

