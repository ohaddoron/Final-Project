function analysis = create_analysis (clu1,res1,clu2,res2,samples_offset) 

cluster_labels1=unique(clu1);
cluster_labels2=unique(clu2);

N_spike1=numel(res1);
N_spike2=numel(res2);


analysis=nan(N_spike1,2);
analysis(:,1)=clu1;


for i=1:N_spike1
    [diff, idx]=min(abs((res1(i)-res2)));
    if diff<=samples_offset
        try
            analysis(i,2)=clu2(idx);
        catch
            ...
        end
    else
        analysis(i,2)=0;
    end
end