function  [im,real_goal,real_rot] = replicate_trim_and_fill_new_loop2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show,varargin)

global ppp

[use_boundary,boundary,thresh] = getPrmDflt(varargin,{'use_boudary',0,'boundary',[],'thresh',0.2}, 1);

if(boundary.top && boundary.bottom && boundary.left && boundary.right)
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);    
    if(good_size_test(real_goal,nr,nc))
        return;
    end
elseif(boundary.top && boundary.bottom)
    boundary_temp = set_boundary(boundary,'top',1,'bottom',1);
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary_temp);
    score_temp = create_score(real_goal,nr,nc,ppp);
    if(score_temp(1)>=thresh && good_size_test(real_goal,nr,nc))
        return;
    end
elseif(boundary.left && boundary.right)
    boundary_temp = set_boundary(boundary,'left',1,'right',1);
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary_temp);
    score_temp = create_score(real_goal,nr,nc,ppp);
    if(score_temp(1)>=thresh && good_size_test(real_goal,nr,nc))
        return;
    end
end

if(boundary.rot~=-1)    %% if boundary.rot is known
    
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
        return;
    end
    if(score(1) < thresh || ~good_size_test(real_goal,nr,nc))
        
        %% Top test        
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        
        %% Left test
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        
        %% Bottom test
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        
        %% Right test
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
    end
    
else  %% if boundary.rot is not known
    
    %% try this first
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_v3(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
        return;
    end
    
    %% try boundary.rot == 0    
    boundary.rot = 0;
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    if(score_temp(1) > score(1))  % better scores, update
        im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
        score = score_temp;
    end
    if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
        return;
    end
    
    if(score(1) < thresh || ~good_size_test(real_goal,nr,nc))
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
    end
    
    %% try boundary.rot == 1
    boundary.rot = 1;
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    if(score(1)>=thresh)
        return;
    end
    
    if(score(1) < thresh || ~good_size_test(real_goal,nr,nc))
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        if(score(1)>=thresh && good_size_test(real_goal,nr,nc))
            return;
        end
    end
    
end

if(score(1) < thresh)
    warning('probably fails, take care \n');
end


end

function test = good_size_test(real_goal,nr,nc)
    test = ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr));
end