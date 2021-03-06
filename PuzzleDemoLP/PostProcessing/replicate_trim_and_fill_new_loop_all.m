function  [im,max_rank_score,sols,real_goal,real_rot,real_goal_bk,real_rot_bk] = replicate_trim_and_fill_new_loop_all(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show,varargin)

global ppp

[use_boundary,boundary,speed_up] = getPrmDflt(varargin,{'use_boudary',0,'boundary',[],'speed_up',0}, 1);

thresh = size(SCO,1)-2*(nr+nc);
sols = []; boundary_rot = boundary.rot;

[Blocks_top_list,Rots_top_list] = get_AssemblyBlocks(SCO,BlocksInfo,label,nr,nc,'boundary',boundary,'speed_up',speed_up);

%% 1st solution
if(boundary.top && boundary.bottom && boundary.left && boundary.right)
    [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,4);
    [sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
else
    [sols,done] = try_dummy(sols);
end

%% 2st solution
if(boundary.top && boundary.bottom)
    boundary = set_boundary(boundary,'top',1,'bottom',1);
    [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,2);
    [sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
else
    [sols,done] = try_dummy(sols);
end

%% 3rd solution
if((boundary.left && boundary.right))
    boundary = set_boundary(boundary,'left',1,'right',1);
    [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,3);
    [sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
else
    [sols,done] = try_dummy(sols);
end

[Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,1);

%% 4th solution
if(boundary.rot~=-1)
    boundary_rot = boundary.rot;
    if(~(boundary.top && boundary.bottom) || ~(boundary.left && boundary.right))
        if(boundary.top && boundary.bottom)
            [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,2);
        elseif(boundary.left && boundary.right)
            [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,3);
        else
            [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,1);
        end
        [sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    else
        [sols,done] = try_dummy(sols);
    end
else
    [sols,done] = try_dummy(sols);
end

boundary_rot = -1;

%% try this first
[sols,done] = another_try(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,thresh,show,0);
% [sols,done] = another_try(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,thresh,1);
[sols,done] = another_try(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,thresh,show,1);

%% try boundary.rot == 0
boundary.rot = 0;
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'top',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'left',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'bottom',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'right',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);

%% try boundary.rot == 1
boundary.rot = 1;
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'top',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'left',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'bottom',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
boundary = set_boundary(boundary,'right',1);
[sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);

[im,max_rank_score,real_goal,real_rot,real_goal_bk,real_rot_bk] = get_im_from_sols(sols);

score = create_score(real_goal,nr,nc,ppp);
if(score(1) < thresh)
    warning('probably fails, take care \n');
end

end

function [sols,done] = try_boundary(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh)

global ppp

% [im,real_goal,real_rot,rank_score] = replicate_trim_and_fill_new_fast(SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
% [im,real_goal,real_rot,rank_score] = replicate_trim_and_fill_new_fast(SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,1,'boundary',boundary);
[im,real_goal,real_rot,rank_score,real_goal_bk,real_rot_bk] = replicate_trim_and_fill_new_fast(SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);

score = create_score(real_goal,nr,nc,ppp);
num_sols = size(sols,2);
sols{num_sols+1}.im = im;
sols{num_sols+1}.real_rot = real_rot;
sols{num_sols+1}.real_goal = real_goal;

sols{num_sols+1}.real_rot_bk = real_rot_bk;
sols{num_sols+1}.real_goal_bk = real_goal_bk;

sols{num_sols+1}.rank_score = rank_score;
sols{num_sols+1}.score = score;
sols{num_sols+1}.boundary = boundary;
sols{num_sols+1}.rot = boundary_rot;

if(rank_score >= thresh && good_size_test(real_goal,nr,nc))
    done = 1;
else
    done = 0;
end

end

function [sols,done] = try_dummy(sols)

num_sols = size(sols,2);
sols{num_sols+1}.im = [];
sols{num_sols+1}.real_rot = [];
sols{num_sols+1}.real_goal = [];
sols{num_sols+1}.real_rot_bk = [];
sols{num_sols+1}.real_goal_bk = [];
sols{num_sols+1}.rank_score = -inf;
sols{num_sols+1}.score = [0 0 0];
sols{num_sols+1}.boundary = [];
sols{num_sols+1}.rot = -1;
done = 0;

end

function [sols,done] = another_try(sols,SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,thresh,show,fill_method)

[im,real_goal,real_rot,rank_score,real_goal_bk,real_rot_bk] = replicate_trim_and_fill_v3_fast(SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,show,fill_method);

global ppp

score = create_score(real_goal,nr,nc,ppp);
num_sols = size(sols,2);
sols{num_sols+1}.im = im;
sols{num_sols+1}.real_rot = real_rot;
sols{num_sols+1}.real_goal = real_goal;

sols{num_sols+1}.real_rot_bk = real_rot_bk;
sols{num_sols+1}.real_goal_bk = real_goal_bk;

sols{num_sols+1}.rank_score = rank_score;
sols{num_sols+1}.score = score;
sols{num_sols+1}.boundary = [];
sols{num_sols+1}.rot = -1;

if(rank_score >= thresh && good_size_test(real_goal,nr,nc))
    done = 1;
else
    done = 0;
end

end

function test = good_size_test(real_goal,nr,nc)

test = ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr));

end

function [Blocks_top,Rots_top] = get_blocks_from_list(Blocks_top_list,Rots_top_list,num)

% num: 1 do nothing, 2 do top & bottom, 3 do left & right, 4 do top & bottom and left & right
Blocks_top = Blocks_top_list{num};
Rots_top = Rots_top_list{num};

end