%% noise analysis, save the images and plot the results of different solutions

% 432 540 805 2360 3300 5015 10375 22834
dataset.piece_num = [432 540 805 2360 3300 5015 10375 22834];
dataset.nr = [18 20 23 40 50 59 83 123];
dataset.nc = [24 27 35 59 66 85 125 185];
dataset.im_num = [20 20 20 3 3 20 20 20];

num = 1; % which dataset to run
dataset_path = sprintf('../../Dataset/%d/png/',dataset.piece_num(num));
im_num = dataset.im_num(num);

kk = 1;
iter = 5;
method = 2;
doType2 = 1;
thresh = 0.7;
buddy_check = 1;
loop_check = 0;
loop_check2 = 0;
rigid_conncomp = 1; % use rigid component motion consraint

% add_imnoise = 1;

sample_num = 5;
noise_list = [300 500 700 1000 2000];

save_path_root = [dataset_path sprintf('kk_%d_iter_%g_thresh_%g_method_%d_match_%d_%d_%d/', ...
    kk,iter,thresh,method,buddy_check,loop_check,loop_check2)];

sols_scores_all = [];
sols_scores_samples_all = [];

for noise_level = noise_list
    
    scores = [];
    perfects = [];
    
    sols_scores_total = zeros(16,4,im_num*sample_num);
    
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
        save_path = [save_path sprintf('imgnoise_%d/',noise_level)];
        
        for sample = 1:sample_num
            
            sols_scores = [];
            rank_scores = [];
            
            %             data = load(fullfile(save_path,'sols_sample_1.mat'));
            data = load(fullfile(save_path,sprintf('sols_sample_%d.mat',sample)));
            sols_num = size(data.sols,2);
            
            %% save all the solutions
            for sol = 1:sols_num
                sols_scores_temp = data.sols{sol}.score;
                sols_scores_sol = [sols_scores_temp sols_scores_temp(1)==1];
                sols_scores = [sols_scores;sols_scores_sol];
                rank_scores = [rank_scores;data.sols{sol}.rank_score];
            end
            %% find the best solution
            [val,ind] = max(rank_scores);
            sols_scores = [sols_scores;sols_scores(ind,:)];
            sols_scores_total(:,:,(k-1)*sample_num+sample) = sols_scores;
            
        end
        
    end
    
    sols_scores_mean = sum(sols_scores_total,3);
    sols_scores_mean(:,1:3) = sols_scores_mean(:,1:3)./im_num;
    
    sols_scores_samples_all = [sols_scores_samples_all;sols_scores_total];

end

prepare_data_for_R