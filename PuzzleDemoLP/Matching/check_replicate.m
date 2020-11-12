%% check if whether blocks is replicated four times
function BlocksInfo = check_replicate(BlocksInfo,piece_num)

Blocks = BlocksInfo.Blocks;
block_num = size(Blocks,1);
tag = zeros(block_num,1);
pass = zeros(block_num,1);

block_ind_all_list = cell(block_num,1);

for i = 1:block_num
    block = Blocks{i};
    block = block(block>0);
    ind_all = get_all_ind(block(:),piece_num);
    block_ind_all_list{i,1} = sort(ind_all);
end

st = 1;

for i = 1:block_num
    
    if(~tag(i))  % if this block is not tagged yet
        tag(i) = st;
        ind_all_i = block_ind_all_list{i,1};
        % find all other three corresponding blocks
        for j = 1:block_num
            if(tag(j))
                continue;
            else
               ind_all_j = block_ind_all_list{j,1};
               if(length(ind_all_i) == length(ind_all_j) && length(ind_all_i) == sum(ind_all_i == ind_all_j))
                   tag(j) = st;
               end
            end
        end
        if(sum(tag == st) == 4)
            pass(tag == st) = 1;
        end
        st = st + 1;        
    end    
end

% tag 

pass = logical(pass);

% %% for those who failed, divide into two parts
% Blocks_div = BlocksInfo.Blocks(~pass);
% Blocks_Rot_div = BlocksInfo.Blocks_Rot(~pass);
% Blocks_Img_div = BlocksInfo.Blocks_Img(~pass);

BlocksInfo.Blocks = BlocksInfo.Blocks(pass);
BlocksInfo.Blocks_Rot = BlocksInfo.Blocks_Rot(pass);
BlocksInfo.Blocks_Img = BlocksInfo.Blocks_Img(pass);

end