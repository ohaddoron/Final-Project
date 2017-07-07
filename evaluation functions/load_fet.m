% this function is used to load fet files created by KlustaKwik
% fet files hold the features extracted after performing PCA channel-wise
% on the detected spikes. The first entry to the fet file is the number of
% features extracted, thus, this is used and then discarded in the final
% fet variable returned. The number of channels in the recording and the
% number of featrues extracted for each channel are provided for the
% function. The resulting fet variable has nfet amount of rows.
% The number of cols matches the amount of spikes detected


% path2fet - pathway to fet file
% nchans - number of channels in the recording
% nfet - num of features to extract
function fet = load_fet (path2fet,nchans,nfet)

fid = fopen(path2fet);
C = textscan(fid,'%f');
fclose(fid);
a = C{1};
num_fet = a(1);
a(1) = [];
fet = reshape(a,num_fet,length(a)/num_fet);
fet = fet(1:(nchans*nfet),:);
end 