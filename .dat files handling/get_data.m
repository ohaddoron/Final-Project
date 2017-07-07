% path2dat - pathway to the raw dat file
% path2results - pathway to results folder. if does not exist, the function
% will create folder

function path2results = get_data 

%% get data from user
waitfor(helpdlg('Select data folders.'));
path2results = uipickfiles;


