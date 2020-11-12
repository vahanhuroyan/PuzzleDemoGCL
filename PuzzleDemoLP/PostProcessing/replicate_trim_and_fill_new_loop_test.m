function  [im,real_goal,real_rot,sols] = replicate_trim_and_fill_new_loop_test(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show,varargin)

global ppp

[use_boundary,boundary] = getPrmDflt(varargin,{'use_boudary',0,'boundary',[]}, 1);

thresh = size(SCO,1)-2*(nr+nc);
sols = []; boundary_bk = boundary;

if(boundary.top && boundary.bottom && boundary.left && boundary.right)
    
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    %     if(done)
    %         [im,real_goal,real_rot,sols] = get_im_from_sols(sols);
    %         return
    %     end
    
elseif(boundary.top && boundary.bottom)
    
    boundary = set_boundary(boundary,'top',1,'bottom',1);
    
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
elseif(boundary.left && boundary.right)
    
    boundary = boundary_bk;
    boundary = set_boundary(boundary,'left',1,'right',1);
    
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
end

if(boundary.rot~=-1)    %% if boundary.rot is known
    
    if(~(boundary.top && boundary.bottom) || ~(boundary.left && boundary.right))
        boundary_rot = boundary.rot;
        [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    end
    
    %% Top test
    boundary = set_boundary(boundary,'top',1);
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
    %% Left test
    boundary = set_boundary(boundary,'left',1);
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
    %% Bottom test
    boundary = set_boundary(boundary,'bottom',1);
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
    %% Right test
    boundary = set_boundary(boundary,'right',1);
    boundary_rot = boundary.rot;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
else  %% if boundary.rot is not known
    
    boundary_rot = -1;
    
    %% try this first
    [sols,done] = another_try(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,thresh,show);
    
    %% try boundary.rot == 0
    boundary.rot = 0;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'top',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'left',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'bottom',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'right',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
    %% try boundary.rot == 1
    boundary.rot = 1;
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'top',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'left',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'bottom',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    boundary = set_boundary(boundary,'right',1);
    [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh);
    
end

[im,real_goal,real_rot] = get_im_from_sols(sols);

score = create_score(real_goal,nr,nc,ppp);
if(score(1) < thresh)
    warning('probably fails, take care \n');
end

end

function [sols,done] = try_boundary(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,boundary,boundary_rot,thresh)

global ppp

[im,real_goal,real_rot,rank_score] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
score = create_score(real_goal,nr,nc,ppp);
num_sols = size(sols,2);
sols{num_sols+1}.im = im;
sols{num_sols+1}.real_rot = real_rot;
sols{num_sols+1}.real_goal = real_goal;
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

function [sols,done] = another_try(sols,SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,thresh,show)

[im,real_goal,real_rot,rank_score] = replicate_trim_and_fill_v3(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show);

global ppp

score = create_score(real_goal,nr,nc,ppp);
num_sols = size(sols,2);
sols{num_sols+1}.im = im;
sols{num_sols+1}.real_rot = real_rot;
sols{num_sols+1}.real_goal = real_goal;
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