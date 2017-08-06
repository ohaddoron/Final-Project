function detection_results = detection_comparison ( fpaths, offset )
%% init
nFolders = length(fpaths);
detection_results = nan(7,nFolders);
for i = 1 : nFolders
    KS_path = fullfile(fpaths{i},'KS');
    OLM_path = fullfile(fpaths{i},'OLM');
    RTS_path = fullfile(fpaths{i},'RTS');
    [ detection_results(:,i) ] = compare_detection(KS_path,OLM_path,RTS_path ,offset );
end
    