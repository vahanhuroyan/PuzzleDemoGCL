%% get the possible pieces of the block that can be matched
function block_piece = get_possible_piece(block,boundary)

filled = block>0;
neiNum = imfilter(uint8(filled), [0 1 0; 1 0 1; 0 1 0]);

block_piece = block(neiNum > 0 & neiNum < 4);
block_piece = block_piece(:);

% if the size of the block is correct
% do something special for boundary pieces
if(~boundary)  
    % left boundary
    ind = find(neiNum(:,1) == 3);
    block_piece = setdiff(block_piece,ind);
    % right boundary
    ind = find(neiNum(:,end) == 3);
    block_piece = setdiff(block_piece,ind);
    % top boundary
    ind = find(neiNum(1,:) == 3);
    block_piece = setdiff(block_piece,ind);
    % bottom boundary
    ind = find(neiNum(end,:) == 3);
    block_piece = setdiff(block_piece,ind);
    % corner
    if(neiNum(1,1) == 2)
        block_piece = setdiff(block_piece,ind);
    end
    if(neiNum(1,end) == 2)
        block_piece = setdiff(block_piece,ind);
    end
    if(neiNum(end,1) == 2)
        block_piece = setdiff(block_piece,ind);
    end
    if(neiNum(end,end) == 2)
        block_piece = setdiff(block_piece,ind);
    end
end

block_piece = block_piece(block_piece>0);