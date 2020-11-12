%% segment the merged block into separate ones
function [blocks,blocks_rot,blocks_img,info_break] = segment_gt(block,block_rot,block_img,piece_num)

info_break = [];

% check if the block need to be segemented
block_piece = block(block>0);
block_piece = block_piece(:);
block_num = length(block_piece);
block_piece_all = get_all_ind(block_piece,piece_num);
block_piece_all = unique(block_piece_all);

pp = size(block_img,1)/size(block_rot,1);

if(length(block_piece_all) < 4*block_num && size(block,1)*size(block,2) > piece_num)  % something going wrong
% if(length(block_piece_all) < 4*block_num)  % something going wrong
% if(length(block_piece_all) < 3*block_num)  % something going wrong
    
    %% try divide the block into two pieces in the midddle
    [rr,cc] = size(block);    
    
    if(rr > 1 && cc >1)
    
        rrt = floor(rr/2);
        cct = floor(cc/2);

        %% count the number in the middle
        row_num = sum(block(rrt,:) > 0) + sum(block(rrt+1,:) > 0);
        col_num = sum(block(:,cct) > 0) + sum(block(:,cct+1) > 0);

        if(row_num < col_num)  % cut from row
            block1 = block(1:rrt,:);
            block2 = block(rrt+1:end,:);        
            info_break = [block(rrt,:)' block(rrt+1,:)';block(rrt+1,:)' block(rrt,:)'];
            info_break = info_break(info_break(:,1)>0 & info_break(:,2)>0 ,:);
            block1_rot = block_rot(1:rrt,:);
            block2_rot = block_rot(rrt+1:end,:);        
            block1_img = block_img(1:rrt*pp,:,:);
            block2_img = block_img(rrt*pp+1:end,:,:);
        else   % cut from column
            block1 = block(:,1:cct);
            block2 = block(:,cct+1:end);
            block1_rot = block_rot(:,1:cct);
            block2_rot = block_rot(:,cct+1:end);
            block1_img = block_img(:,1:cct*pp,:);
            block2_img = block_img(:,cct*pp+1:end,:);
            info_break = [block(:,cct) block(:,cct+1);block(:,cct+1) block(:,cct)];
            info_break = info_break(info_break(:,1)>0 & info_break(:,2)>0 ,:);
        end

        blocks{1} = block1;
        blocks{2} = block2;

        blocks_rot{1} = block1_rot;
        blocks_rot{2} = block2_rot;

        blocks_img{1} = block1_img;
        blocks_img{2} = block2_img;
        
    end
    
else
    
    blocks{1} = block;
    blocks_rot{1} = block_rot;
    blocks_img{1} = block_img;
    
end

end