%% trying to find out boundary location
function boundary = find_boundary_new(BlocksInfo,nr,nc)

block_num = size(BlocksInfo.Blocks,1);

if(block_num == 0)
    boundary.rot = -1;
    boundary.left = 0;
    boundary.right = 0;
    boundary.top = 0;
    boundary.bottom = 0;
    boundary.block = [];
    return;
end

block_dimen_list = zeros(block_num,2);
for i = 1:block_num
    block = BlocksInfo.Blocks{i};
    block_dimen_list(i,:) = size(block);
end
block_dimen = block_dimen_list(:,1) .* block_dimen_list(:,2);
[~,ind] = max(block_dimen);
max_block = BlocksInfo.Blocks{ind,1};

%% in case something happens, we crop out the holes out of the image
max_block = my_crop(max_block);
max_block_dimen = size(max_block);

top = 0; bottom = 0; left = 0; right = 0; rot = -1;
% do not need to do anything
if((max_block_dimen(1) == nr && max_block_dimen(2) == nc) || (max_block_dimen(2) == nr && max_block_dimen(1) == nc))
    top = 1; bottom = 1; left = 1; right = 1;
end

if(max_block_dimen(1) == nc)
    top = 1; bottom = 1;
elseif(max_block_dimen(2) == nc)
    left = 1; right = 1;
end

if(max_block_dimen(2) > nr)  % proper rotation
    rot = 0;
elseif(max_block_dimen(1) > nr)  % rotated
    rot = 1;
end

% if(max(max_block_dimen) > nr)
%     
%     % check top row and bottom row
%     top_row = max_block(1,:);
%     bottom_row = max_block(end,:);
%     top_num = sum(top_row>0);
%     bottom_num = sum(bottom_row>0);
%     
%     bottom_piece = bottom_row(bottom_row>0);
%     mask = info_del_track(:,4) == 3;
%     bottom_label = ismember(bottom_piece,info_del_track(mask,1));
%     bottom_good_num = sum(bottom_label);
%     
%     top_piece = top_row(top_row>0);
%     mask = info_del_track(:,4) == 1;
%     top_label = ismember(top_piece,info_del_track(mask,1));
%     top_good_num = sum(top_label);
%     
%     if(top_good_num > bottom_good_num)
%         top = 1;
%     elseif(top_good_num < bottom_good_num)
%         bottom = 1;
%     else
%         notsure = 1;
%     end
%     
%     % check left and right
%     left_col = max_block(:,1);
%     right_col = max_block(:,end);
%     left_num = sum(left_col>0);
%     right_num = sum(right_col>0);
%     
%     left_piece = left_col(left_col>0);
%     mask = info_del_track(:,4) == 4;
%     left_label = ismember(left_piece,info_del_track(mask,1));
%     left_good_num = sum(left_label);
%     
%     right_piece = right_col(right_col>0);
%     mask = info_del_track(:,4) == 2;
%     right_label = ismember(right_piece,info_del_track(mask,1));
%     right_good_num = sum(right_label);
%     
%     if(right_good_num > left_good_num)
%         right = 1;
%     elseif(right_good_num < left_good_num)
%         left = 1;
%     else
%         notsure = 1;
%     end
% end

boundary.rot = rot;
boundary.left = left;
boundary.right = right;
boundary.top = top;
boundary.bottom = bottom;
boundary.block = max_block;