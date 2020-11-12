%% get neighbors from a block
function neigh = get_neigh_from_block(block,block_rot)

neigh = [];

% bottom up
block1 = block(2:end,:);
block2 = block(1:end-1,:);
rot1 = block_rot(2:end,:);
rot2 = block_rot(1:end-1,:);

block1 = block1(:);
block2 = block2(:);
rot1 = rot1(:);
rot2 = rot2(:);

msk = block1 > 0 & block2 > 0;
msk = msk(:);

neigh = [neigh; block1(msk) block2(msk) rot1(msk) rot2(msk) ones(sum(msk(:)),1)];

% left right
block1 = block(:,1:end-1);
block2 = block(:,2:end);
rot1 = block_rot(:,1:end-1);
rot2 = block_rot(:,2:end);

block1 = block1(:);
block2 = block2(:);
rot1 = rot1(:);
rot2 = rot2(:);

msk = block1 > 0 & block2 > 0;
neigh = [neigh; block1(msk) block2(msk) rot1(msk) rot2(msk) ones(sum(msk(:)),1)*2];

% top down
block1 = block(1:end-1,:);
block2 = block(2:end,:);
rot1 = block_rot(1:end-1,:);
rot2 = block_rot(2:end,:);

block1 = block1(:);
block2 = block2(:);
rot1 = rot1(:);
rot2 = rot2(:);

msk = block1 > 0 & block2 > 0;
neigh = [neigh; block1(msk) block2(msk) rot1(msk) rot2(msk) ones(sum(msk(:)),1)*3];

% right left
block1 = block(:,2:end);
block2 = block(:,1:end-1);
rot1 = block_rot(:,2:end);
rot2 = block_rot(:,1:end-1);

block1 = block1(:);
block2 = block2(:);
rot1 = rot1(:);
rot2 = rot2(:);

msk = block1 > 0 & block2 > 0;
neigh = [neigh; block1(msk) block2(msk) rot1(msk) rot2(msk) ones(sum(msk(:)),1)*4];