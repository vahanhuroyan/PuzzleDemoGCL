%% crop out unused boundary

function [block,del_r,del_c] = my_crop(block)

del_r = sum(block,2) <= 0;
del_c = sum(block,1) <= 0;

block(del_r,:) = [];
block(:,del_c) = [];

end