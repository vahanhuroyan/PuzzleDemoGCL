function SCO = SCO_update(SCO,sol,varargin)

[rm_boundary,method,label,do_replicate,piece_num] = getPrmDflt(varargin,{'rm_boundary',1, ...
    'method', 'old','label',[],'do_replicate',0,'piece_num',0}, 1);

% holes = size(SCO);

if(strcmp(method,'conneced_comp'))
    label_num = length(setdiff(unique(label),-1));
    for i = 1:label_num
        ind = find(label == i);
        if(~do_replicate)
            SCO(ind,ind,:) = inf;
            %         holes(ind,ind,:) = inf;
        else
            ind_all = get_all_ind(ind,piece_num);
            SCO(ind,ind_all,:) = inf;
            SCO(ind_all,ind,:) = inf;            
        end
    end
end

if(isstruct(sol))
    Blocks = sol.Blocks;
    Blocks_Rot = sol.Blocks_Rot;
    num = size(Blocks,1);
    for i = 1:num
        real_goal = Blocks{i};
        rot = Blocks_Rot{i};
        SCO = update_help(SCO,real_goal,rot,varargin);
    end
end

end

function SCO = update_help(SCO,real_goal,rot,varargin)

[rm_boundary,method,label,do_replicate,piece_num] = getPrmDflt(varargin,{'rm_boundary',1,'method', 'old','label',[], ...
    'do_replicate',0,'piece_num',0}, 1);

good_size = 0;
if(size(SCO,1) == size(real_goal,1)*size(real_goal,2))
    fprintf('correct size \n');
    good_size = 1;
end
if(do_replicate && piece_num == size(real_goal,1)*size(real_goal,2))
    fprintf('correct size \n');
    good_size = 1;
end

mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]'; %what is the symmetry? %this will cut processing time in half.

mat = [1 5 9 13;
    2 6 10 14;
    3 7 11 15;
    4 8 12 16;
    2 6 10 14;
    3 7 11 15;
    4 8 12 16;
    1 5  9 13;
    3 7 11 15;
    4 8 12 16;
    1 5  9 13;
    2 6 10 14;
    4 8 12 16;
    1 5  9 13;
    2 6 10 14;
    3 7 11 15];

[h,w,c] = size(SCO);

for i = 1:4
    
    switch i
        
        case 1
            % layer 1, top
            id1 = real_goal(2:end,:);
            id2 = real_goal(1:end-1,:);
            rot1 = rot(2:end,:);
            rot2 = rot(1:end-1,:);
            bd1 = real_goal(1,:);
            %             bd2 = real_goal(end,:);
            bd_rot1 = rot(1,:);
            %             bd_rot2 = rot(end,:);
        case 2
            % layer 2, right
            id1 = real_goal(:,1:end-1);
            id2 = real_goal(:,2:end);
            rot1 = rot(:,1:end-1);
            rot2 = rot(:,2:end);
            bd1 = real_goal(:,end);
            %             bd2 = real_goal(:,1);
            bd_rot1 = rot(:,end);
            %             bd_rot2 = rot(:,1);
        case 3
            % layer 3, bottom
            id1 = real_goal(1:end-1,:);
            id2 = real_goal(2:end,:);
            rot1 = rot(1:end-1,:);
            rot2 = rot(2:end,:);
            bd1 = real_goal(end,:);
            %             bd2 = real_goal(1,:);
            bd_rot1 = rot(end,:);
            %             bd_rot2 = rot(1,:);
        case 4
            % layer 4, left
            id1 = real_goal(:,2:end);
            id2 = real_goal(:,1:end-1);
            rot1 = rot(:,2:end);
            rot2 = rot(:,1:end-1);
            bd1 = real_goal(:,1);
            %             bd2 = real_goal(:,end);
            bd_rot1 = rot(:,1);
            %             bd_rot2 = rot(:,end);
    end
    
    id1 = id1(:);
    id2 = id2(:);
    mask = id1 > 0 & id2 > 0;
    if(strcmp(method,'conneced_comp'))
        mask = mask & label(max(id1,1)) == label(max(id2,1));
    end
    
    id1 = id1(mask);
    id2 = id2(mask);
    
    rot1 = rot1(mask);
    rot2 = rot2(mask);
    
    if(size(SCO,3) == 4)
        
        SCO(id1,:,i) = inf;
        SCO(:,id1,mirror(i)) = inf;
        SCO(:,id2,i) = inf;
        SCO(id2,:,mirror(i)) = inf;
        
        %         holes(id1,:,i) = inf;
        %         holes(:,id1,mirror(i)) = inf;
        %         holes(:,id2,i) = inf;
        %         holes(id2,:,mirror(i)) = inf;
        
    else    % unfortunatelly, have to consider rotation as well
        
        map = mat(4*(i-1)+1:4*i,:);
        
        for k = 1:4
            
            temp = map(:,k);
            
            ind_st = id1+ (temp(rot1)-1)*h*w;
            ind_end = id1+ (w-1)*h+(temp(rot1)-1)*h*w;
            step = h;
            for num = 1:length(ind_st)
                SCO(ind_st(num):step:ind_end(num)) = inf;
            end
            
            ind_st_mirror = 1 + (id1-1)*h + (mirror(temp(rot1))-1)*h*w;
            ind_end_mirror = h + (id1-1)*h + (mirror(temp(rot1))-1)*h*w;
            step_mirror = 1;
            for num = 1:length(ind_st_mirror)
                SCO(ind_st_mirror(num):step_mirror:ind_end_mirror(num)) = inf;
            end
            
            ind_st = 1 + (id2-1)*h + (temp(rot1)-1)*h*w;
            ind_end = h + (id2-1)*h + (temp(rot1)-1)*h*w;
            step = 1;
            for num = 1:length(ind_st)
                SCO(ind_st(num):step:ind_end(num)) = inf;
            end
            
            ind_st_mirror = id2+ (mirror(temp(rot1))-1)*h*w;
            ind_end_mirror = id2+ (w-1)*h+(mirror(temp(rot1))-1)*h*w;
            step_mirror = h;
            for num = 1:length(ind_st_mirror)
                SCO(ind_st_mirror(num):step_mirror:ind_end_mirror(num)) = inf;
            end
            
            %%
            
            %             ind_st = id1+ (temp(rot1)-1)*h*w;
            %             ind_end = id1+ (w-1)*h+(temp(rot1)-1)*h*w;
            %             step = h;
            %             holes(ind_st:step:ind_end) = inf;
            %
            %             ind_st_mirror = 1 + (id1-1)*h + (mirror(temp(rot1))-1)*h*w;
            %             ind_end_mirror = h + (id1-1)*h + (mirror(temp(rot1))-1)*h*w;
            %             step_mirror = 1;
            %             holes(ind_st_mirror:step_mirror:ind_end_mirror) = inf;
            %
            %             ind_st = 1 + (id2-1)*h + (temp(rot1)-1)*h*w;
            %             ind_end = h + (id2-1)*h + (temp(rot1)-1)*h*w;
            %             step = 1;
            %             holes(ind_st:step:ind_end) = inf;
            %
            %             ind_st_mirror = id2+ (mirror(temp(rot1))-1)*h*w;
            %             ind_end_mirror = id2+ (w-1)*h+(mirror(temp(rot1))-1)*h*w;
            %             step_mirror = h;
            %             holes(ind_st_mirror:step_mirror:ind_end_mirror) = inf;
            
            
        end
        
    end
    
    if(good_size && rm_boundary)  % set the boudary piece
        
        bd1 = bd1(:);
        %         bd2 = bd2(:);
        
        mask1 = bd1 > 0;
        %         mask2 = bd2 > 0;
        
        bd1 = bd1(mask1);
        %         bd2 = bd2(mask2);
        
        bd_rot1 = bd_rot1(mask1);
        %         bd_rot2 = bd_rot2(mask2);
        
        if(size(SCO,3) == 4)
            
            SCO(bd1,:,i) = inf;
            SCO(:,bd1,mirror(i)) = inf;
            %             SCO(:,bd2,i) = inf;
            %             SCO(bd2,:,mirror(i)) = inf;
            
        else
            
            map = mat(4*(i-1)+1:4*i,:);
            for k = 1:4
                temp = map(:,k);
                
                ind_st = bd1+ (temp(bd_rot1)-1)*h*w;
                ind_end = bd1+ (w-1)*h+(temp(bd_rot1)-1)*h*w;
                step = h;
                for num = 1:length(ind_st)
                    SCO(ind_st(num):step:ind_end(num)) = inf;
                end
                
                ind_st_mirror = 1 + (bd1-1)*h + (mirror(temp(bd_rot1))-1)*h*w;
                ind_end_mirror = h + (bd1-1)*h + (mirror(temp(bd_rot1))-1)*h*w;
                step_mirror = 1;
                for num = 1:length(ind_st_mirror)
                    SCO(ind_st_mirror(num):step_mirror:ind_end_mirror(num)) = inf;
                end
                
                %                 ind_st = 1 + (bd2-1)*h + (temp(bd_rot1)-1)*h*w;
                %                 ind_end = h + (bd2-1)*h + (temp(bd_rot1)-1)*h*w;
                %                 step = 1;
                %                 for num = 1:length(ind_st)
                %                     SCO(ind_st(num):step:ind_end(num)) = inf;
                %                 end
                %
                %                 ind_st_mirror = bd2+ (mirror(temp(bd_rot1))-1)*h*w;
                %                 ind_end_mirror = bd2+ (w-1)*h+(mirror(temp(bd_rot1))-1)*h*w;
                %                 step_mirror = h;
                %                 for num = 1:length(ind_st_mirror)
                %                     SCO(ind_st_mirror(num):step_mirror:ind_end_mirror(num)) = inf;
                %                 end
                
                %%
                %
                %                 ind_st = bd1+ (temp(bd_rot1)-1)*h*w;
                %                 ind_end = bd1+ (w-1)*h+(temp(bd_rot1)-1)*h*w;
                %                 step = h;
                %                 holes(ind_st:step:ind_end) = inf;
                %
                %                 ind_st_mirror = 1 + (bd1-1)*h + (mirror(temp(bd_rot1))-1)*h*w;
                %                 ind_end_mirror = h + (bd1-1)*h + (mirror(temp(bd_rot1))-1)*h*w;
                %                 step_mirror = 1;
                %                 holes(ind_st_mirror:step_mirror:ind_end_mirror) = inf;
                %
                %                 ind_st = 1 + (bd2-1)*h + (temp(bd_rot1)-1)*h*w;
                %                 ind_end = h + (bd2-1)*h + (temp(bd_rot1)-1)*h*w;
                %                 step = 1;
                %                 holes(ind_st:step:ind_end) = inf;
                %
                %                 ind_st_mirror = bd2+ (mirror(temp(bd_rot1))-1)*h*w;s
                %                 ind_end_mirror = bd2+ (w-1)*h+(mirror(temp(bd_rot1))-1)*h*w;
                %                 step_mirror = h;
                %                 holes(ind_st_mirror:step_mirror:ind_end_mirror) = inf;
                %
                
            end
            
        end
        
    end
    
end

end

% %% check the result
% hole_test = holes(:,:,1);