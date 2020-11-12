%% select the best one from the all the possible solutions
%% rank all the solutions according to the rank_score
function [im,max_rank_score,real_goal,real_rot,real_goal_bk,real_rot_bk] = get_im_from_sols(sols)

sol_num = size(sols,2);
rank_scores = zeros(sol_num,1);

for i = 1:sol_num
    rank_scores(i) = sols{i}.rank_score;   
end

[max_rank_score,ind] = max(rank_scores);
im = sols{ind}.im;
real_goal = sols{ind}.real_goal;
real_rot = sols{ind}.real_rot;

real_goal_bk = sols{ind}.real_goal_bk;
real_rot_bk = sols{ind}.real_rot;