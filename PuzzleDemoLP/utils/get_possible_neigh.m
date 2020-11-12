%% get the possible neighbor position of each hole to fill for this block
function neigh_info = get_possible_neigh(block,block_rot,boundary)

% count existing neighbors
filled = block>0;
ss = size(block);
[rr,cc] = find(block==0);

neiNum = imfilter(uint8(filled), [0 1 0; 1 0 1; 0 1 0]);
ii = sub2ind(size(neiNum), rr,cc);
nn = neiNum(ii);

% have hole neighbors
msk = nn > 0;
nn  = nn(msk);
rr  = rr(msk);
cc  = cc(msk);

num = size(rr,1);

% determine the next one to sort.
[~,bb] = sort(nn,'descend');

hole_num = num;

if(boundary)
    hole_num = hole_num + ... 
               length(find(block(1,:))) + ...
               length(find(block(end,:))) + ...
               length(find(block(:,1))) + ...
               length(find(block(:,end)));    
end

block_nei_code = cell(hole_num,1);
block_nei_rot  = cell(hole_num,1);
block_nei_ids  = cell(hole_num,1);
block_nei_ind  = cell(hole_num,1);

rr = rr(bb);
cc = cc(bb);

% for all the holes
for i = 1:num
    
    neighbors = [rr(i)-1 cc(i);
                 rr(i)   cc(i)-1;
                 rr(i)   cc(i)+1;
                 rr(i)+1 cc(i)];
    
    %position of the neighbor, relative to the hole (hole is piece 1).
    %   1   top     of P1 w/ bottom of P2
    %   2   right   of P1 w/ left of P2
    %   3   bottom  of P1 w/ top of P2
    %   4   left    of P1 w/ right of P2
    nei_code = [1;4;2;3];
    
    %make sure to keep out edge spots:
    good = neighbors(:,1)>0 & neighbors(:,2)>0 & neighbors(:,1)<=ss(1) & neighbors(:,2)<=ss(2);
    neighbors = neighbors(good,:);
    nei_code = nei_code(good);
    
    neighbors_i = sub2ind(ss, neighbors(:,1),neighbors(:,2)); %
    %   neighborsThere = filled(neighbors_i);
    %  neighbors = neighbors(good,:); %these are the neighbors.
    %  nei_code = nei_code(good);
    
    nei_ids = block(neighbors_i);% This is who lives nearby
    nei_rot = block_rot(neighbors_i);% This is the current rotation of the pieces.
    good = nei_ids>0;  %only consider neighbors that are occupied.

    nei_code = nei_code(good);
    nei_rot = nei_rot(good);
    nei_ids = nei_ids(good);
    neighbors = neighbors(good,:);
    
    block_nei_code{i} = nei_code;
    block_nei_rot{i}  = nei_rot;
    block_nei_ids{i}  = nei_ids;
    block_nei_ind{i}  = neighbors;
    
end

st = num;

%% If we are happy to add boundary pieces
if(boundary)
    % left boundary
    ind = find(block(:,1));
    if(~isempty(ind))
        for i = 1:length(ind)
            st = st + 1;
            block_nei_code{st} = 2;
            block_nei_rot{st}  = block_rot(ind(i),1);
            block_nei_ids{st}  = block(ind(i),1);
            block_nei_ind{st}  = [ind(i) 1];
        end
    end
    % right boundary
    ind = find(block(:,end));
    if(~isempty(ind))
        for i = 1:length(ind)
            st = st + 1;
            block_nei_code{st} = 4;
            block_nei_rot{st}  = block_rot(ind(i),end);
            block_nei_ids{st}  = block(ind(i),end);
            block_nei_ind{st}  = [ind(i) ss(2)];
        end
    end
    % top boundary
    ind = find(block(1,:));
    if(~isempty(ind))
        for i = 1:length(ind)
            st = st + 1;
            block_nei_code{st} = 3;
            block_nei_rot{st}  = block_rot(1,ind(i));
            block_nei_ids{st}  = block(1,ind(i));
            block_nei_ind{st}  = [1 ind(i)];
        end
    end
    % bottom boundary
    ind = find(block(end,:));
    if(~isempty(ind))
        for i = 1:length(ind)
            st = st + 1;
            block_nei_code{st} = 1;
            block_nei_rot{st}  = block_rot(end,ind(i));
            block_nei_ids{st}  = block(end,ind(i));
            block_nei_ind{st}  = [ss(1) ind(i)];
        end
    end
end

neigh_info.block_nei_code = block_nei_code;
neigh_info.block_nei_rot = block_nei_rot;
neigh_info.block_nei_ids = block_nei_ids;
neigh_info.block_nei_ind = block_nei_ind;