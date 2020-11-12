function  [im,real_goal,real_rot] = replicate_trim_and_fill_new_loop(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show,varargin)

global ppp

[use_boundary,boundary] = getPrmDflt(varargin,{'use_boudary',0,'boundary',[]}, 1);

if(boundary.top && boundary.bottom && boundary.left && boundary.right)
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);    
    if(((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
elseif(boundary.top && boundary.bottom)
    boundary_temp = set_boundary(boundary,'top',1,'bottom',1);
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary_temp);
    score_temp = create_score(real_goal,nr,nc,ppp);
    if(score_temp(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
elseif(boundary.left && boundary.right)
    boundary_temp = set_boundary(boundary,'left',1,'right',1);
    [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary_temp);
    score_temp = create_score(real_goal,nr,nc,ppp);
    %     if(score_temp(1)>=0.2)
    if(score_temp(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
end

if(boundary.rot~=-1)    %% if boundary.rot is known
    
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    %     if(score(1)>=0.2)
    if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
    if(score(1) < 0.2 || ~((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
    end
    
else  %% if boundary.rot is not known
    
    %% try this first
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_v3(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    %     if(score(1)>=0.2)
    if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
    
    %% try boundary.rot == 0
    
    boundary.rot = 0;
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    %         im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    %         score = score_temp;
    if(score_temp(1) > score(1))  % better scores, update
        im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
        score = score_temp;
    end
    %     if(score(1)>=0.2)
    if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        return;
    end
    
    %     if(score(1) < 0.2)
    if(score(1) < 0.2 || ~((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
    end
    
    %% try boundary.rot == 1
    boundary.rot = 1;
    [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
    score_temp = create_score(real_goal_temp,nr,nc,ppp);
    im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
    score = score_temp;
    if(score(1)>=0.2)
        return;
    end
    
    %     if(score(1) < 0.2)
    if(score(1) < 0.2 || ~((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
        boundary = set_boundary(boundary,'top',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'left',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'bottom',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
        boundary = set_boundary(boundary,'right',1);
        [im_temp,real_goal_temp,real_rot_temp] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0,'boundary',boundary);
        score_temp = create_score(real_goal_temp,nr,nc,ppp);
        if(score_temp(1) > score(1))  % better scores, update
            im = im_temp; real_goal = real_goal_temp; real_rot = real_rot_temp;
            score = score_temp;
        end
        %         if(score(1)>=0.2)
        if(score(1)>=0.2 && ((size(real_goal,1) == nr && size(real_goal,2) == nc) || (size(real_goal,1) == nc && size(real_goal,2) == nr)))
            return;
        end
    end
    
end

if(score(1) < 0.2)
    warning('probably fails, take care \n');
end