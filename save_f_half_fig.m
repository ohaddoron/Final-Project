a = zeros(8,1);
path1 = 'D:\MATLAB\Results\test\m258r1\m258r1\1 - 8\KK';
path2 = 'D:\MATLAB\Results\test\m258r1\m258r1\1 - 8\KS';
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
    [], [], 3,[],true);
a(1) = f_half(end);
o_path = 'D:\MATLAB\Results\test\m258r1\m258r1\9 - 16';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(2) = f_half(end);
o_path = 'D:\MATLAB\Results\test\m258r1\m258r1\17 - 24';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(3) = f_half(end)
o_path = 'D:\MATLAB\Results\test\m531r1\m531r1\17 - 24';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(4) = f_half(end)
o_path = 'D:\MATLAB\Results\test\m531r1\m531r1\25 - 32';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(5) = f_half(end)
o_path = 'D:\MATLAB\Results\test\m649r1\m649r1\9 - 16';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(6) = f_half(end)
o_path = 'D:\MATLAB\Results\test\m649r1\m649r1\17 - 24';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(7) = f_half(end)
o_path = 'D:\MATLAB\Results\test\m649r1\m649r1\25 - 32';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
o_path = 'D:\MATLAB\Results\test\m649r1\m649r1\25 - 32';
path1 = fullfile(o_path,'KK');
path2 = fullfile(o_path,'KS');
[f_half,miss1,miss2,hits] = calc_f_half ( path1 , path2 , [], [], ...
[], [], 3,[],true);
a(8) = f_half(end)