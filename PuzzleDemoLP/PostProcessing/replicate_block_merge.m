%% for replication use, merge blocks which have the same piece, although with different ids and rotations
%% piece_num is the number of pieces of a single image
function block = replicate_block_merge(block,block2,piece_num)

% get the relative rotation between these two blocks
block2_all = get_all_ind(block2(:),piece_num);
comm = intersect(block(:),block2_all(:));
comm = comm(1);

if(comm <= piece_num)
    comm_list = [comm comm+piece_num comm+2*piece_num comm+3*piece_num];
elseif(comm > piece_num && comm <= 2*piece_num)
    comm_list = [comm comm+piece_num comm+2*piece_num comm-piece_num];
elseif(comm > 2*piece_num && comm <= 3*piece_num)
    comm_list = [comm comm+piece_num comm-2*piece_num comm-piece_num];
elseif(comm > 3*piece_num && comm <= 4*piece_num)
    comm_list = [comm comm-3*piece_num comm-2*piece_num comm-piece_num];
end

if(any(ismember(comm_list(1),block2(:))))
    rot2do = 0;
elseif(any(ismember(comm_list(2),block2(:))))
    rot2do = 3;
elseif(any(ismember(comm_list(3),block2(:))))
    rot2do = 2;
elseif(any(ismember(comm_list(4),block2(:))))
    rot2do = 1;    
end

block2 = imrotate(block2,90*rot2do);
mask = block2 > 0;
block2(mask) = block2(mask) + rot2do*piece_num;
mask = block2 > 4*piece_num;
block2(mask) = block2(mask) - 4*piece_num;

% modify the number of piece inside block2

[r1,c1] = find(block == comm);
[r2,c2] = find(block2 == comm);

[m1,n1] = size(block);
[m2,n2] = size(block2);

min_top = min(1,r1-r2+1);
min_left = min(1,c1-c2+1);
max_down = max(m1,m2+r1-r2);
max_right = max(n1,n2+c1-c2);

block_new = zeros(max_down-min_top+1,max_right-min_left+1);
block_new(min_top+r1-r2:min_top+r1-r2+m2-1,min_left+c1-c2:min_left+c1-c2+n2-1) = block2;
temp = block_new(1-min_top+1:m1-min_top+1,1-min_left+1:n1-min_left+1);
temp(block>0) = block(block > 0);
block_new(1-min_top+1:m1-min_top+1,1-min_left+1:n1-min_left+1) = temp;

intersect_num = length(intersect(block(block>0),block2(block2>0)));
overlap_num = sum(block(:)>0) + sum(block2(:)>0) - sum(block_new(:)>0);

% if(intersect_num ~= overlap_num)
%    error('not consistent between two overlap blocks\n');
% end

block = block_new;

% diff_mat = bsxfun(@minus,block(:),block2(:)');
% diff_value = mode(diff_mat(:));
% rot2do = diff_value/piece_num;
