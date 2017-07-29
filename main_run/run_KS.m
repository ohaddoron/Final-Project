function run_KS ( fpath ) 
%% cycle through shanks
for k = 1 : length( fpath )
    cur_paths = dir(fpath{k});
    cur_paths(1:2) = [];
    cur_paths(~[cur_paths.isdir]) = [];
    names = {cur_paths.name};
    names_int = cellfun(@str2num, names);
    sorted_names = cellfun(@num2str,num2cell(sort(names_int)),'Un',false);
    for j = 1 : length(sorted_names)
        path2results{j} = fullfile(fpath{k},sorted_names{j});
    end
    run_kilosort(path2results)
end