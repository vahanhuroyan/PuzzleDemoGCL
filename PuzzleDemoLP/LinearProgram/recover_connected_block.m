%% recover connected components from x and label
function [label,BlocksInfo,info,info_del] = recover_connected_block(label,x,n,ap,PP,varargin)

[rot,info,pause_t,plot_res,do_replicate, ...
    break_conflict_inside_ccomp,keep_prev,prev_info,break_no_loop,buddy_check,loop_check,loop_check2] = ...
    getPrmDflt(varargin,{'rot',[],'info',[],'pause_t',1,'plot_res',0,'do_replicate',0,'break_conflict_inside_ccomp',0, ...
    'keep_prev',0,'prev_info',[],'break_no_loop',0,'buddy_check',0,'loop_check',0,'loop_check2',0},1);

label_list = setdiff(unique(label),-1);
label_num = length(label_list);

Blocks = cell(label_num,1);
Blocks_Rot = cell(label_num,1);
Blocks_Img = cell(label_num,1);

st = 0;
info_del = [];

if(do_replicate)
   nrnc = n/4;
else
   nrnc = n; 
end

for k = 1:label_num
    
    ind = find(label == label_list(k));
    xx = x(ind);
    yy = x(ind+n);
    
    % recover the image and block use xi and yi
    minx = min(xx);
    miny = min(yy);
    maxx = max(xx);
    maxy = max(yy);
    
    nr_sol = round(maxx - minx + 1);
    nc_sol = round(maxy - miny + 1);
    
    block = zeros(nr_sol,nc_sol);
    block_rot = zeros(nr_sol,nc_sol);   % to be updated
    block_img = zeros(nr_sol*PP,nc_sol*PP,3);
    
    pieces_conflict = []; % track all the conflicting pieces
    for j = 1:nc_sol
        for i = 1:nr_sol
            valx = minx + i -1;
            valy = miny + j -1;
            id = (xx > valx-0.1 & xx < valx+0.1 & yy > valy-0.1 & yy < valy+0.1);
            if(sum(id) == 1)
                block(i,j) = ind(id);
                block_img((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:) = ap{ind(id)};
                block_rot(i,j) = rot(ind(id));
            else
                block(i,j) = -sum(id);
                pieces_conflict = [pieces_conflict;ind(id)];
            end
        end
    end
    
    if(break_no_loop)
        
        if(isempty(pieces_conflict))
            
            Blocks{st+1,1} = block;
            Blocks_Rot{st+1,1} = block_rot;
            Blocks_Img{st+1,1} = block_img;            
            
            block_mask = block ~= 0;
            if(sum(sum(abs(block_rot-block_mask))) ~= 0)
                error('block and block_rot not consistent');
            end
            
            st = st + 1;
            
        else
            
            msk = block > 0;
            pieces_good = block(msk);
            pieces_good = pieces_good(:);
            pieces_all = [pieces_good;pieces_conflict];
            
            mask_used = ismember(info(:,1),pieces_all,'rows') | ismember(info(:,2),pieces_all,'rows');
            ind_used = find(mask_used);
            info_used = info(mask_used,:);
            
            mask_conflict = ismember(info_used(:,1),pieces_conflict,'rows') | ismember(info_used(:,2),pieces_conflict,'rows');
            ind_conflict = ind_used(mask_conflict);
            info_conflict = info_used(mask_conflict,:);
            
            if(loop_check2)
                [~,has_loop] = info_filter_loop2(info_conflict,do_replicate,nrnc);
            else
                has_loop = true(size(info_conflict,1),1);
            end
            
            mask_del = ~has_loop;
            
            if(keep_prev) % keep all previous info
                mask_keep = ismember(info_conflict(:,1),prev_info(:,1),'rows') & ismember(info_conflict(:,2),prev_info(:,2),'rows');
                mask_del = mask_del & ~mask_keep;
            end
            
            ind_del = ind_conflict(mask_del,:);
            temp = find(mask_conflict);
            temp = temp(mask_del);
            info_used(temp,:) = [];
            
            info_del = [info_del;info(ind_del,:)];
            info(ind_del,:) = [];
            
            if(buddy_check)
                info = info_filter(info,do_replicate,nrnc);
            end
                
            graph = sparse(info_used(:,1),info_used(:,2),ones(size(info_used,1),1),n,n);
            graph = graph + graph';
            [~,label_new_k] = graphconncomp(graph,'Directed',0,'Weak',1);
            label_new_k = label_new_k';
            label_new_k = label_new_k(pieces_all);
            
            label_unique_list_k = unique(label_new_k);
            label_num_k = length(label_unique_list_k);
            
            % How many labels are there
            for i = 1:label_num_k
                
                ind_k = find(label_new_k == label_unique_list_k(i));
                xxx = x(pieces_all(ind_k));
                yyy = x(pieces_all(ind_k)+n);
                
                % recover the image and block use xi and yi
                minxx = min(xxx);
                minyy = min(yyy);
                maxxx = max(xxx);
                maxyy = max(yyy);
                
                nr_sol = round(maxxx - minxx + 1);
                nc_sol = round(maxyy - minyy + 1);
                
                block_k = zeros(nr_sol,nc_sol);
                block_rot_k = zeros(nr_sol,nc_sol);   % to be updated
                block_img_k = zeros(nr_sol*PP,nc_sol*PP,3);
                
                for mm = 1:nc_sol
                    for nn = 1:nr_sol
                        valxx = minxx + nn -1;
                        valyy = minyy + mm -1;
                        id_k = (xxx > valxx-0.1 & xxx < valxx+0.1 & yyy > valyy-0.1 & yyy < valyy+0.1);
                        if(sum(id_k) == 1)
                            block_k(nn,mm) = pieces_all(ind_k(id_k));
                            block_img_k((nn-1)*PP+1:nn*PP,(mm-1)*PP+1:mm*PP,:) = ap{pieces_all(ind_k(id_k))};
                            block_rot_k(nn,mm) = rot(pieces_all(ind_k(id_k)));
                        else
%                             block_k(nn,mm) = -sum(id_k);
                        end
                    end
                end
                
                Blocks{st+1,1} = block_k;
                Blocks_Rot{st+1,1} = block_rot_k;
                Blocks_Img{st+1,1} = block_img_k;
                
                block_mask = block_k ~= 0;
                if(sum(sum(abs(block_rot_k-block_mask))) ~= 0)
                    error('block and block_rot not consistent');
                end
                
                st = st + 1;
                
            end
            
        end
        
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%previous code
        %%%
        
        %% might be disconnected
        msk = block > 0;
        L = bwlabel(msk, 4);
        label_connected = L(msk);
        
        if(break_conflict_inside_ccomp)
            
            %% do something with conflicting pieces inside a single connected component
            %  delete those edges related with conflict pieces and redo the
            %  labelling for the pieces of this component
            if(~isempty(pieces_conflict))
                
                pieces_good = block(msk);
                pieces_good = pieces_good(:);
                pieces_all = [pieces_good;pieces_conflict];
                
                mask_used = ismember(info(:,1),pieces_all,'rows') | ismember(info(:,2),pieces_all,'rows');
                ind_used = find(mask_used);
                info_used = info(mask_used,:);
                mask_del = ismember(info_used(:,1),pieces_conflict,'rows') | ismember(info_used(:,2),pieces_conflict,'rows');
                
                if(keep_prev) % keep all previous info
                    mask_keep = ismember(info_used(:,1),prev_info(:,1),'rows') & ismember(info_used(:,2),prev_info(:,2),'rows');
                    mask_del = mask_del & ~mask_keep;
                end
                
                info_used(mask_del,:) = [];
                
                info_del = [info_del;info(ind_used(mask_del),:)];
                info(ind_used(mask_del),:) = [];
                
                if(buddy_check)
                    info = info_filter(info,do_replicate,nrnc);
                end
                    
                graph = sparse(info_used(:,1),info_used(:,2),ones(size(info_used,1),1),n,n);
                graph = graph + graph';
                [~,label_new] = graphconncomp(graph,'Directed',0,'Weak',1);
                label_new = label_new';
                label_new = label_new(pieces_good);
                
                %% combine connected component labelling and new constructed labelling
                label_new_list = unique(label_new);
                num1 = length(label_new_list);
                label_connected_list = unique(label_connected);
                num2 = length(label_connected_list);
                maxnum = num1*num2;
                
                label_combined = label_connected;
                for i = 1:num2
                    ind = label_combined == label_connected_list(i);
                    res = unique(label_new(ind));
                    res_num = length(res);
                    if(res_num > 1)
                        map = zeros(res_num,1);
                        map(res) = maxnum+1:maxnum+res_num;
                        label_combined(ind) = map(label_new(ind));
                        maxnum = maxnum+res_num;
                    end
                end
                
                %% map to 1 to k
                label_list_temp = unique(label_combined);
                map = zeros(length(label_list_temp),1);
                map(label_list_temp) = 1:length(label_list_temp);
                label_combined = map(label_combined);
                
                label_connected = label_combined;
                
            end
            
        end
        
        %% update L and comp_list
        L = zeros(size(block));
        L(msk) = label_connected;
        comp_list = setdiff(L(:),0);
        num = length(comp_list);
        
        % How many connected components are there
        for i = 1:num
            block_i = block;
            block_rot_i = block_rot;
            block_i(L ~= comp_list(i)) = 0;
            block_rot_i(L ~= comp_list(i)) = 0;
            % crop unused regions
            block_i = my_crop(block_i);
            block_rot_i = my_crop(block_rot_i);
            
            % create image based on final block_i
            [r,c] = size(block_i);
            block_img_i = zeros(r*PP,c*PP,3);
            for mm = 1:r
                for nn = 1:c
                    if(block_i(mm,nn) > 0)
                        block_img_i((mm-1)*PP+1:mm*PP,(nn-1)*PP+1:nn*PP,:) = imrotate(ap{block_i(mm,nn)},90*(block_rot_i(mm,nn)-1));
                    end
                end
            end
            
            Blocks{st+1,1} = block_i;
            Blocks_Rot{st+1,1} = block_rot_i;
            Blocks_Img{st+1,1} = block_img_i;
            
            block_mask = block_i ~= 0;
            if(sum(sum(abs(block_rot_i-block_mask))) ~= 0)
                error('block and block_rot not consistent');
            end
            
            st = st + 1;
        end
        
    end
    
end

% % %% If there is replication
% % if(do_replicate)
% %     % enforce the consistent block constraint to the Blocks we got
% %     % to make sure we get four exactly copy of each block
% %     num = size(Blocks,1);
% %     edge = [];
% %     for i = 1:num
% %         for j = i+1:num
% %             block_i = Blocks{i};
% %             block_j = Blocks{j};
% %             temp_i = block_i(block_i > 0);
% %             temp_j = block_j(block_j > 0);
% %             if(any(ismember(temp_i(:),get_all_ind(temp_j(:),n/4))))
% %                edge = [edge;[i j]];
% %             end
% %         end
% %     end
% %     % create connected block graph based on block connection matrix
% %     mat = sparse(edge(:,1),edge(:,2),ones(size(edge,1),1),num,num);
% %     mat = mat + mat';
% %     [~,block_label] = graphconncomp(mat,'Directed',0,'Weak',1);
% %     block_label = block_label';
% %     block_label_list = unique(block_label);
% %     new_block_num = length(block_label_list);  % should get four replicates
% %     Blocks_new = cell(new_block_num,1);
% %
% %     for i = 1:new_block_num
% %         %% find the biggest block in this group and add pieces incrementally
% %         mask = block_label == block_label_list(i);
% %         blocks = Blocks(mask);
% %         ind = find(mask);
% %         block_numel = cellfun(@numel,blocks);
% %         [val,ind_sort] = sort(block_numel,'descend');
% %         block_new = blocks{ind_sort(1)};
% %         for j = 2:size(blocks,1)
% %             block_j = blocks{ind_sort(j)};
% %             block_new = replicate_block_merge(block_new,block_j,n/4);
% %         end
% %         Blocks_new{i,1} = block_new;
% %     end
% %     %% replicate 4 times
% %     for i = 2:4
% %         for k = 1:new_block_num
% %              temp = imrotate(Blocks_new{k},90*(i-1));
% %              temp(temp>0) = temp(temp>0) + (i-1)*n/4;
% %              temp(temp>n) = temp(temp>n) - n;
% %              Blocks_new{(i-1)*new_block_num+k,1} = temp;
% %         end
% %     end
% %     block_num = size(Blocks_new,1);
% %     Blocks_Rot_new = cell(block_num,1);
% %     Blocks_Img_new = cell(block_num,1);
% %     for i = 1:block_num
% %        block_i = Blocks_new{i};
% %        Blocks_Rot_new{i} = block_i>0;
% %        [r,c] = size(block_i);
% %        block_img_i = zeros(r*PP,c*PP,3);
% %        for mm = 1:r
% %            for nn = 1:c
% %                if(block_i(mm,nn) > 0)
% %                    block_img_i((mm-1)*PP+1:mm*PP,(nn-1)*PP+1:nn*PP,:) = ap{block_i(mm,nn)};
% %                end
% %            end
% %        end
% %        Blocks_Img_new{i} = block_img_i;
% %     end
% %
% %     Blocks = Blocks_new;
% %     Blocks_Rot = Blocks_Rot_new;
% %     Blocks_Img = Blocks_Img_new;
% %
% % end

%% remove blocks which have only one piece
keep = cellfun(@numel,Blocks) > 1;
Blocks = Blocks(keep);
Blocks_Rot = Blocks_Rot(keep);
Blocks_Img = Blocks_Img(keep);

%% update labels as well
label(:) = ones(size(label))*(-1);
for i = 1:size(Blocks,1)
    ind = unique(Blocks{i}(:));
    ind = ind(ind>0);
    label(ind) = i;
end

temp = setdiff(unique(label),-1);
mask = label == -1;
label(mask) = 1;
map = zeros(max(label),1);
map(temp) = 1:length(temp);
label = map(label);
label(mask) = -1;

BlocksInfo.Blocks = Blocks;
BlocksInfo.Blocks_Rot = Blocks_Rot;

%% check Blocks_Rot is consistent with Blocks
block_num = size(BlocksInfo.Blocks,1);
for i = 1:block_num
   block = BlocksInfo.Blocks{i};
   rot = BlocksInfo.Blocks_Rot{i};
   block_mask = block ~= 0;
   if(sum(sum(abs(rot-block_mask))) ~= 0)
        error('block and block_rot not consistent');
   end
end

BlocksInfo.Blocks_Img = Blocks_Img;

% %% plot the recovered Blocks
if(plot_res)
    
    label_list = setdiff(unique(label),-1);
    label_num = length(label_list);
    
    for k = 1:label_num
        figure(100+k)
        im = Blocks_Img{k,1};
        if(max(im(:)) > 255)
            imshow(uint16(im));
        else
            imshow(uint8(im));
        end
        if(pause_t == -1)
            pause
        else
            pause(pause_t);
        end
    end
    
end