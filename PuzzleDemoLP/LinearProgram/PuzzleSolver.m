function x = PuzzleSolver(SCO,ScrambleRotations,kk,thresh)

%% replicate 4 times more pieces and solve position only
if(ScrambleRotations)
    SCO_all = get_all_SCO(SCO);
    info_all = get_candidate_and_weight(SCO_all);
    %% formulate linear programs from candidate patches and weights
    [f,A,b,Aeq,beq] = lp_from_patch_and_weight(SCO_all,info_all);
    lb = -inf(length(f),1);
    ub = inf(length(f),1);
    [x, fval, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub);
    clear A Aeq b beq lb ub SCO
end

%% get candidate patches and corresponding weights
info = get_candidate_and_weight(SCO,kk,thresh);

%% recover image from gt ind(debug only)
% im = recover_im_from_gt(nr,nc,ap,PP,ppp);
% imshow(im);

%% test candidate matches(debug only)
% check_random_match(info,ap,ppp,imlist_new,nr,nc,PP,1);

%% use TRWS to solve rotation first

%% use complex numbers to solve rotation first
if(ScrambleRotations)
    [f,A,b,Aeq,beq] = lp_from_patch_and_weight_rot(SCO,info);
    lb = -inf(length(f),1);
    ub = inf(length(f),1);
    [x, fval, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub);
end

%% use mixed integer programming solve rotation first
if(ScrambleRotations)
    [f,A,b,Aeq,beq] = mip_from_patch_and_weight_rot(SCO,info);
    lb = -inf(length(f),1);
    ub = inf(length(f),1);
    intcon = size(SCO,1)+2*size(info,1)+1:size(SCO,1)+3*size(info,1);
    [x, fval, exitflag] = intlinprog(f,intcon, A, b, Aeq, beq, lb, ub);
end

% %% only keep the pieces which are connected
% keep_id = union(info(:,1),info(:,2));
% id_map = zeros(nc*nr,1);
% id_map(keep_id) = 1:length(keep_id);
% SCO = SCO(keep_id,keep_id,:);
% info(:,1) = id_map(info(:,1));
% info(:,2) = id_map(info(:,2));

%% formulate linear programs from candidate patches and weights
[f,A,b,Aeq,beq] = lp_from_patch_and_weight(SCO,info);
lb = -inf(length(f),1);
ub = inf(length(f),1);
[x, fval, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub);

% clear A Aeq b beq lb ub SCO

% intcon = 1:2*nr*nc;
% [x, fval, exitflag] = intlinprog(f,intcon, A, b, Aeq, beq, lb, ub);

end