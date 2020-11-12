%% BlocksInfo cut

function [BlocksInfo_new,info_break_new] = BlocksInfo_cut_all(BlocksInfo,piece_num)

BlocksInfo_new = BlocksInfo;
block_num = size(BlocksInfo.Blocks,1);

info_break_new = [];

for i = 1:block_num

    block = BlocksInfo.Blocks{i};
    block_rot = BlocksInfo.Blocks_Rot{i};
    block_img = BlocksInfo.Blocks_Img{i};
    
    [blocks,blocks_rot,blocks_img,info_break] = segment_gt_all(block,block_rot,block_img,piece_num);
    info_break_new = [info_break_new;info_break];
    
    num = length(blocks);
    
    if(num > 1)
        
        for j = 1:num
            
            block_j = blocks{j};
            block_rot_j = blocks_rot{j};
            block_img_j = blocks_img{j};

            pp = size(block_img_j,1)/size(block_j,1);
            col_del = find(sum(block_j==0,1) == size(block_j,1));
            row_del = find(sum(block_j==0,2) == size(block_j,2));

            col_del = col_del(:);
            row_del = row_del(:);
            block_j(row_del,:) = [];
            block_j(:,col_del) = [];
            block_rot_j(row_del,:) = [];
            block_rot_j(:,col_del) = [];

            mask = block_j>0;
            L = bwlabel(mask,4);
            label = L(L>0);
            label_sel = mode(label);
            mask = L == label_sel;
            block_j(~mask) = 0;
            block_rot_j(~mask) = 0;

            row_del_ind = bsxfun(@plus,1:pp,(row_del-1)*pp);
            col_del_ind = bsxfun(@plus,1:pp,(col_del-1)*pp);
            block_img_j(row_del_ind(:),:,:) = [];
            block_img_j(:,col_del_ind(:),:) = [];

            for m = 1:size(block_j,1)
                for n = 1:size(block_j,2)
                    if(block_j(m,n) == 0)
                        block_img_j(pp*(m-1)+1:pp*m,pp*(n-1)+1:pp*n,:) = 0;
                    end
                end
            end

            BlocksInfo_new.Blocks{end+1} = block_j;
            BlocksInfo_new.Blocks_Rot{end+1} = block_rot_j;
            BlocksInfo_new.Blocks_Img{end+1} = block_img_j;

        end

    else

        BlocksInfo_new.Blocks{end+1} = blocks{1};
        BlocksInfo_new.Blocks_Rot{end+1} = blocks_rot{1};
        BlocksInfo_new.Blocks_Img{end+1} = blocks_img{1};

    end

end

BlocksInfo_new.Blocks(1:block_num) = [];
BlocksInfo_new.Blocks_Rot(1:block_num) = [];
BlocksInfo_new.Blocks_Img(1:block_num) = [];
