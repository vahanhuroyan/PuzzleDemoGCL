%% delete block index which are repeated
function block = del_block_repeat(block,piece_num)

% block_ind = block(block>0);
block_all_ind =  get_all_ind(block(block>0),piece_num);
unique_block_all_ind = unique(block_all_ind);
if(length(block_all_ind) == length(unique_block_all_ind))  % don't need to do anything
    return;
else
    count_block = histc(block_all_ind,unique_block_all_ind); %# get the count of elements
    mask = count_block > 1;
    del_ind = unique_block_all_ind(mask);
    mask = ismember(block(:),del_ind);
    block(mask) = 0;
end