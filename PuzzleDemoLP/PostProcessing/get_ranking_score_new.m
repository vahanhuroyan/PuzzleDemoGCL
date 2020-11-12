%% compute ranking scores for final solution
function [norm_score,norm_outlier_score] = get_ranking_score(real_goal,SCO)

% thresh = 1.3;
% thresh = 1.5;
% thresh = 2;

normSCO = get_normSCO(SCO,size(SCO,3));

norm_score = 0;
norm_outlier_score = 0;
[height,width] = size(real_goal);

% make sure we get the size right and there is no whole
num_total_piece = size(SCO,1);
if(num_total_piece == height*width*4)
   num_piece = num_total_piece/4;
else
   num_piece = num_total_piece;
end
missing_mask = real_goal == 0;
missing_piece_num = sum(sum(missing_mask));
if(num_piece ~= height*width || missing_piece_num > 0)
    norm_score = -inf;
    norm_outlier_score = inf;
    return;
end

t = 0.001; normSCO = max(normSCO,t);

% sum over all the possible distances
% case 1, down top match
p1 =  real_goal(2:end,:);
p2 =  real_goal(1:end-1,:);
p = (p2(:)-1)*num_total_piece + p1(:);
norm_score = norm_score + sum(1./normSCO(p));

% sum over all the possible distances
% case 2, left right match
p1 =  real_goal(:,1:end-1);
p2 =  real_goal(:,2:end);
p = num_total_piece*num_total_piece + (p2(:)-1)*num_total_piece + p1(:);
norm_score = norm_score + sum(1./normSCO(p));

% sum over all the possible distances
% case 3, top down match
p1 =  real_goal(1:end-1,:);
p2 =  real_goal(2:end,:);
p = 2*num_total_piece*num_total_piece + (p2(:)-1)*num_total_piece + p1(:);
norm_score = norm_score + sum(1./normSCO(p));

% sum over all the possible distances
% case 4, right left match
p1 =  real_goal(:,2:end);
p2 =  real_goal(:,1:end-1);
p = 3*num_total_piece*num_total_piece + (p2(:)-1)*num_total_piece + p1(:);
norm_score = norm_score + sum(1./normSCO(p));

norm_score = norm_score/2;