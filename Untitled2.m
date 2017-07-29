n_match_score = bsxfun(@rdivide,match_score,S); % normalized match_score

result.match_score = match_score;
result.n_match_score = n_match_score;

%% create matching index
result.matches=nan(nClusters2,1);
n_match_score(S < min_spikes, : ) = -inf;

while max(n_match_score(:)) > thresh
    [~,idx1]=max(n_match_score(:));
    [R,C]=ind2sub(size(n_match_score),idx1);
    if C == 0
        flag = 1;
    end
    result.matches(R)=C;
    n_match_score(R,:)=-inf;
    n_match_score(:,C)=-inf;
%     figure, imagesc(n_match_score); colorbar
%     pause(3);
end