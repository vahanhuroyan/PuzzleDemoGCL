%% configure jigsaw parameters

%% add subdirectories with current folder
% addpath('/home/cvfish/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP');
% addpath(genpath('/cvfish/home/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP'));
% rmpath('/cvfish/home/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP');
addpath(genpath(pwd));

%% add gurobi
addpath('/opt/gurobi652/linux64/matlab');
addpath('/opt/gurobi652/linux64/examples/matlab');

%% information of the dataset
%% number of pieces for each dataset: 432 540 805 2360 3300 5015 10375 22834
% dataset.root_path = '/home/cvfish/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP/Illustration';
dataset.root_path = '/cvfish/home/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP/Illustration';

dataset.piece_num = [4];
dataset.nr = [2];
dataset.nc = [2];
dataset.im_num = [1];
dataset.name_format = ['%d.png  '];

Parameters.PP = 252; % pixels in a piece
Parameters.method = 3; % 1:use ratio as weighting, 2:probabilistic weighting, 3:inverse distance weighting
Parameters.kk = 1; % top kk matches
Parameters.iter = 5; % iteration times

Parameters.doType2 = 0; % run Type2 puzzle
Parameters.speed_up = 1; 
Parameters.ScramblePositions = 1;
Parameters.ScrambleRotations = Parameters.doType2; % scramble rotations
Parameters.rigid_conncomp = 1; % use rigid component motion consraint
Parameters.thresh = 0.8; % matching threshold

if(Parameters.num == 1)
    dataset_path = fullfile(dataset.root_path,sprintf('/%d/png/',dataset.piece_num(Parameters.num)));
else
    dataset_path = fullfile(dataset.root_path,sprintf('/%d/',dataset.piece_num(Parameters.num)));
end

Parameters.dataset_path = dataset_path;
Parameters.im_total = dataset.im_num(Parameters.num);
Parameters.piece_num = dataset.piece_num(Parameters.num);
Parameters.nr = dataset.nr(Parameters.num);
Parameters.nc = dataset.nc(Parameters.num);
Parameters.name_format = dataset.name_format(Parameters.num,:);

%% set matching checking parameters
Parameters.match.buddy_check = 0; % check info_filter
Parameters.match.loop_check =  0; % check info_filter_loop
Parameters.match.loop_check2 = 0; % check info_filter_loop2

%% set parameters of noise experiments
Parameters.noise.add_imnoise = 0;
% Parameters.noise.noise_list = [300 500 700 1000 2000];
Parameters.noise.noise_list = [2000 1000 700 500 300];
Parameters.noise.sample = 5;