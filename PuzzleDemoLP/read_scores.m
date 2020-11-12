function [im,max_rank_score,sols,real_goal] = read_scores(SCO,save_path,ranking_method)

load(fullfile(save_path,'sols.mat'));

%% update the scores of solutions use selected ranking strategy

sols_num = size(sols,2);
new_sols = sols;



switch(ranking_method)

    case 'inliers_minus_outliers/'
        
        for i = 1:sols_num
            real_goal_bk = sols{i}.real_goal;
            rank_score = get_ranking_score_bk(real_goal_bk,SCO);
            rank_score
            new_sols{i}.rank_score = rank_score;
            sols{i}.rank_score
        end
            
        [im,max_rank_score,real_goal,real_rot,real_goal_bk,real_rot_bk] = get_im_from_sols(new_sols);

    case 'sum_weight/'
        
        for i = 1:sols_num
            real_goal_bk = sols{i}.real_goal;
            rank_score = get_ranking_score(real_goal_bk,SCO);
            new_sols{i}.rank_score = rank_score;
        end
        
        [im,max_rank_score,real_goal,real_rot,real_goal_bk,real_rot_bk] = get_im_from_sols(new_sols);
        
end
