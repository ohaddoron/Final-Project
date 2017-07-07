function templates_idx = noise_remover(templates)
% This function will remove correlated noise between channels according to
% the cross correlation between the different channels

%% init
[nchans,nTimePoints,nTemplates] = size(templates);
score = zeros(nTemplates,1);
%% cycle through templates
for n = 1 : nTemplates
    cur_template = templates(:,:,n);
    %% cycle through channels
    temp_score = zeros(nchans,1);
    for c = 1 : nchans
        cur_chan = cur_template(c,:);
        nidx = ~ismember(1:nchans,c);
        temp_score(c) = mean(sum(bsxfun(@times,cur_chan,cur_template(nidx,:))));
    end
    score(n) = mean(temp_score);
%     fprintf('score: %2.4f \n', score(n));
end
templates_idx = find(score < 6e-3);
return