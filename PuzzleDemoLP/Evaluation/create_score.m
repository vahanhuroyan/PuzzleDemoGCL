function score = create_score(real_goal,nr,nc,ppp)

% GI = zeros(nr,nc);
% nr_real = min(size(real_goal,1),nr);
% nc_real = min(size(real_goal,2),nc);
% GI(end-nr_real+1:end,end-nc_real+1:end) = real_goal(end-nr_real+1:end,end-nc_real+1:end);

if(size(real_goal,1) ~= nr)
    real_goal = imrotate(real_goal,90);
end

GI = real_goal;
G_safe = GI;
G_undo = (G_safe<0 | G_safe==0);
G_safe(G_undo) = 1;
G_temptemp = ppp(G_safe);
G_temptemp(G_undo) = 0;
[Res] = EvalPuzzleAssembly(G_temptemp, nc, nr);


GI = imrotate(real_goal,180);
G_safe = GI;
G_undo = (G_safe<0 | G_safe==0);
G_safe(G_undo) = 1;
G_temptemp = ppp(G_safe);
G_temptemp(G_undo) = 0;
[Res2] = EvalPuzzleAssembly(G_temptemp, nc, nr);

total_count = [nr*nc 2*nr*nc-nr-nc nr*nc];

% if(Res(1) > Res2(1))
%     score = Res./total_count;
% else
%     score = Res2./total_count;
% end

if(Res(2) > Res2(2))
    score = Res./total_count;
else
    score = Res2./total_count;
end

%% My own evaluation
% % if(size(real_goal,1)*size(real_goal,2) ~= nr*nc)
% %% if nr > nc
% if(size(real_goal,1) > size(real_goal,2))
%     real_goal = imrotate(real_goal,90);
% end
% score1 = eval_score(real_goal,ppp(1:nr*nc),ones(nr*nc),nr,nc);
% score1 = score1(1,:);
% score2 = eval_score(imrotate(real_goal,180),ppp(1:nr*nc),ones(nr*nc),nr,nc);
% score2 = score2(1,:);
% if(score1(2) > score2(2))
%     score_new = score1;
% else
%     score_new = score2;
% end
% % end
% 
% if(score_new(1) > score(1))
%    score = score_new;
% end
   
%% compute accuracy of the result
% im_gt = imread(imlist_new);
% [val,ind_gt] = sort(ppp);
% ind_sol = goal(:)';
% ind_diff = ind_gt - ind_sol;
% accu = sum(ind_diff == 0)/length(ind_diff);