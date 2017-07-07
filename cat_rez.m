load('D:\MATLAB\Results\m258r1_286\1-8\p1\rez.mat');
orez = rez; clear rez;
load('D:\MATLAB\Results\m258r1_286\1-8\p2\rez.mat');
nrez = rez; clear rez;

orez.st3 = orez.st3(:,1:4);
nrez.st3 = nrez.st3(:,1:4);
nrez.st3(:,1) = nrez.st3(:,1) + max(orez.st3(:,1)) + 1e3;
nrez.st3(:,2) = nrez.st3(:,2) + orez.ops.Nfilt;

rez.st3 = cat(1,orez.st3,nrez.st3);

rez.mu = cat(1,orez.mu,nrez.mu);

rez.ops = orez.ops;

rez.ops.Nfilt = orez.ops.Nfilt + nrez.ops.Nfilt;

rez.iNeigh = cat(2,orez.iNeigh,nrez.iNeigh);

rez.cProj = cat(1,orez.cProj,nrez.cProj);

rez.nbins = cat(1,orez.nbins(1:end-1),nrez.nbins);


rez = merge_posthoc2(rez);


