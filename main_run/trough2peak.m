function t2p = trough2peak ( templates ) 

%% init
templates = double(templates);
[nchans,nTP,nTemplates] = size(templates);
templates_max_channel = nan(nTemplates,nTP);
%% 
for i = 1 :nTemplates
    t2p = zeros(nchans,1);
    for k = 1 : nchans
        [troughs_vals,troughs_locs] = findpeaks(-templates(k,:,i));
        [peaks_vals,peaks_locs] = findpeaks(templates(k,:,i));
        vals = [troughs_vals, peaks_vals];
        locs = [troughs_locs, peaks_locs];
        if isempty(vals) 
            continue
        end
        [~,I] = sort(locs);
        vals = vals(I);
        t2p(k) = max(abs(diff(vals)));
    end
    [~,I] = max(t2p);
    templates_max_channel(i,:) = templates(I,:,i);
end
%%
t2p = nan(nTemplates,1);
for i = 1 : nTemplates
    [~,troughs_locs] = min(templates_max_channel(i,:));
    [~,peaks_locs] = max(templates_max_channel(i,troughs_locs:end));
    peaks_locs = peaks_locs + troughs_locs - 1;
    t2p(i) = peaks_locs - troughs_locs;
end
    


return
