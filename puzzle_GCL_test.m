%
% Written by Vahan Huroyan
%

% requires software gurobi (this is required for the PuzzleDemoLP)

addpath(genpath('PuzzleDemoLP')) % We obtained this code from the authors of Yu et al. work
addpath(genpath('utils'))  


% img_path = 'dataset/540/6.jpg'; % image path
% patch_size = 28; % size of puzzle patches
% cols = 27; % number of puzzle columns
% rows = 20; % number of puzzle rows 

img_path = 'dataset/432/png/10.png'; % image path

patch_size = 28; % size of puzzle patches
cols = 24; % number of puzzle columns
rows = 18; % number of puzzle rows 

number_iter = 5; % number of iterations to possibly correct the mistakes 

[res_all_sol, err_all, real_goal_all, res_all, rotsNum_first, rotsNum] = solve_type_2_img(img_path, patch_size, cols, rows, number_iter);

% output the error values
disp(err_all)

% output of the direct comparison, the neighbors comparison and the largest 
% compon error type errors throughout the iterations;

% for i=1:length(res_all_sol)
%     disp(res_all_sol{i}.score)
% end

% output of the direct comparison, the neighbors comparison and the largest 
% compon error type errors throughout the iterations;

for i=1:length(res_all)
    disp(res_all{i}.score)
end
