%% find the best match from all the pairwise matches and fix this piece during the LP
function fix_id = find_best_match(info,num,do_replicate)

% msk1 = info(:,4) == 1;
% msk2 = info(:,4) == 2;
% msk3 = info(:,4) == 3;
% msk4 = info(:,4) == 4;

msk1 = info(:,4) == 1 & info(:,3) ~= 1;
msk2 = info(:,4) == 2 & info(:,3) ~= 1;
msk3 = info(:,4) == 3 & info(:,3) ~= 1;
msk4 = info(:,4) == 4 & info(:,3) ~= 1;

info1 = info(msk1,:);
info2 = info(msk2,:);
info3 = info(msk3,:);
info4 = info(msk4,:);

if(do_replicate)
    piece_num = 4*num;
else
    piece_num = num;
end

[mask1,locb1] = ismember((1:piece_num)',info1(:,1));
[mask2,locb2] = ismember((1:piece_num)',info2(:,1));
[mask3,locb3] = ismember((1:piece_num)',info3(:,1));
[mask4,locb4] = ismember((1:piece_num)',info4(:,1));
neigh_num = mask1 + mask2 + mask3 + mask4;
weight_sum = zeros(piece_num,1);

mask = neigh_num == 4; % good piece should have 4 good matches
weight_sum(~mask) = 0;

weight_sum(mask) = weight_sum(mask) + info1(locb1(mask),3);
weight_sum(mask) = weight_sum(mask) + info2(locb2(mask),3);
weight_sum(mask) = weight_sum(mask) + info3(locb3(mask),3);
weight_sum(mask) = weight_sum(mask) + info4(locb4(mask),3);

[~,fix_id] = max(weight_sum);