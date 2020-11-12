%% noise analysis

% 432 540 805 2360 3300 5015 10375 22834
dataset.piece_num = [432 540 805 2360 3300 5015 10375 22834];
dataset.nr = [18 20 23 40 50 59 83 123];
dataset.nc = [24 27 35 59 66 85 125 185];
dataset.im_num = [20 20 20 3 3 20 20 20];

num = 1; % which dataset to run
dataset_path = sprintf('../../Dataset/%d/png/',dataset.piece_num(num));
PP = 28; %pixels in a piece
im_num = dataset.im_num(num);

kk = 1;
iter = 5;
method = 2;
doType2 = 0;
thresh = 0.7;
buddy_check = 0;
loop_check = 0;
loop_check2 = 0;
rigid_conncomp = 1; % use rigid component motion consraint

% add_imnoise = 1;
sample_num = 5;
noise_list = [300 500 700 1000 2000];

save_path_root = [dataset_path sprintf('kk_%d_iter_%g_thresh_%g_method_%d_match_%d_%d_%d/', ...
    kk,iter,thresh,method,buddy_check,loop_check,loop_check2)];
    
scores = [];
perfects = [];

for k = 1:im_num

    save_path = [save_path_root sprintf('im_%d/',k)];
    if(~rigid_conncomp)
        save_path = fullfile(save_path,'no_rigid/');
    else
        save_path = fullfile(save_path,'rigid/');
    end
    if(doType2)
        save_path = [save_path 'type2/'];
    end
    
    score_k = load([save_path 'scores.mat']);
    perfect_k = load([save_path 'perfect.mat']);
    scores = [scores;score_k.scores];
    perfects = [perfects;perfect_k.perfect_num];
    
end

score = [mean(scores,1) sum(perfects)]