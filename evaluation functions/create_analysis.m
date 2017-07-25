function analysis = create_analysis (clu1,res1,clu2,res2,samples_offset) 
% Analysis maps clu2 to clu1. If two spikes were registered at the same
% time (concidering the sample offset) according to their respective res 
% files, the respective row in analysis will have the indices of their
% clusters. Otherwise, the row will have the indices of clu1 and 0 at the
% second col.

%% init
% we currently did not attempt to resolve the issue of temporally
% overlapping spike peaks. This is an issue that may be resolved in the
% future.
idx2remove1 = diff(res1) == 0;
idx2remove2 = diff(res2) == 0;

res1(idx2remove1) = [];
res2(idx2remove2) = [];
clu1(idx2remove1) = [];
clu2(idx2remove2) = [];

N_spike1=numel(res1);
N_spike2=numel(res2);

analysis=nan(N_spike1,2);
analysis(:,1)=clu1;
%% match clu
% First, find the res indices matching two different clusters. Once these
% indices are found, place the clu originating from said indices in the
% appropriate location
for i = -samples_offset : samples_offset
    tmp_res2 = res2 + i;
    idx1 = ismember(res1,tmp_res2);
    idx2 = ismember(tmp_res2,res1);
    analysis(idx1,2) = clu2(idx2);
end
analysis(isnan(analysis))=0;
