% Nov 2011. Andy Gallagher

function [newBlock,newRotBlock] = TrimPuzzle_rui(theBlock,theRotBlock,ap,SCO,nr,nc,rotFlag,varargin)
% SHOULD ENFORCE THE SIZE OF THE PUZZLE! ENABLE SEEDING OF THE PIECES?
% ENFORCE THE no-overlap policy.
% enforce single piece additions?
% Quads first, then singles?
%
% locked means that I know how big the puzzle is...
%   Remember, I need a "buffer row" on the top and bottom and left and
%   right.
%
% givenPieces = []; Indexes of pieces that are in the correct postion
% to start with. Assumes "locked" aspect ratio...
%

%    addLots = 0; % instead of iterating, just add singles one after another
% after the initial QuadGrid is formed.
%    v1v2Flag = 1; %choose v1 for giving preference to 4surrounded neighbors, etc.
% v2 is just the most confidenct. (when adding next single)
%
% GI is the array of indexes
% GR is the array of rotations

[use_boundary,boundary] = getPrmDflt(varargin,{'use_boundary',0,'boundary',[]}, 1);

good1 = 0;
good2 = 0;

if(use_boundary)
    top = boundary.top;
    bottom = boundary.bottom;
    left = boundary.left;
    right = boundary.right;
    block = boundary.block;
    rot = boundary.rot;
 
    % top and bottom
    if(top)
        top_piece = block(1,:);
        top_piece = top_piece(top_piece>0);
        [top_row,~] = find(theBlock == top_piece(1));
    end
    if(bottom)
        bottom_piece = block(end,:);
        bottom_piece = bottom_piece(bottom_piece>0);
        [bottom_row,~] = find(theBlock == bottom_piece(1));
    end
    % left and right
    if(left)
        left_piece = block(:,1);
        left_piece = left_piece(left_piece>0);
        [~,left_col] = find(theBlock == left_piece(1));
    end
    if(right)
        right_piece = block(:,end);
        right_piece = right_piece(right_piece>0);
        [~,right_col] = find(theBlock == right_piece(1));
    end
    
    %% we are sure if both left and right, or both top and bottom are right
    if(top && bottom)
        theBlock = theBlock(top_row:bottom_row,:);
        theRotBlock = theRotBlock(top_row:bottom_row,:);
    elseif(left && right)
        theBlock = theBlock(:,left_col:right_col);
        theRotBlock = theRotBlock(:,left_col:right_col);
    end
    
    theBlock_cut = theBlock;
    % top and bottom
    if(top)
        top_piece = block(1,:);
        top_piece = top_piece(top_piece>0);
        [top_row,~] = find(theBlock == top_piece(1));
        theBlock_cut(1:top_row-1,:) = [];        
        good1 = 1;
    elseif(bottom)
        bottom_piece = block(end,:);
        bottom_piece = bottom_piece(bottom_piece>0);
        [bottom_row,~] = find(theBlock == bottom_piece(1));
        theBlock_cut(bottom_row+1:end,:) = [];
        good1 = 1;
    end
    % left and right
    if(left)
        left_piece = block(:,1);
        left_piece = left_piece(left_piece>0);
        [~,left_col] = find(theBlock == left_piece(1));
        theBlock_cut(:,1:left_col-1) = [];
        good2 = 1;
    elseif(right)
        right_piece = block(:,end);
        right_piece = right_piece(right_piece>0);
        [~,right_col] = find(theBlock == right_piece(1));
        theBlock_cut(:,right_col+1:end) = [];
        good2 = 1;
    end

    
    if(rot == 0)  % no rotation
        block_new = zeros(nr,nc);
        [rr,cc] = size(theBlock_cut);
        minr = min(nr,rr);
        minc = min(nc,cc);
        if(left && top)
            block_new(1:minr,1:minc) = theBlock_cut(1:minr,1:minc);        
        elseif(left && right)
            block_new(1:minr,1:minc) = theBlock_cut(1:minr,end-minc+1:end);
        elseif(bottom && top)
            block_new(1:minr,1:minc) = theBlock_cut(end-minr+1:end,1:minc);
        elseif(bottom && right)
            block_new(1:minr,1:minc) = theBlock_cut(end-minr+1:end,end-minc+1:end);
        end
    elseif(rot == 1) % block rotated
        block_new = zeros(nc,nr);
        [rr,cc] = size(theBlock_cut);
        minr = min(nc,rr);
        minc = min(nr,cc);        
%         block_new(1:minr,1:minc) = theBlock_cut(1:minr,1:minc);
        if(top && left)
            block_new(1:minr,1:minc) = theBlock_cut(1:minr,1:minc);        
        elseif(top && right)
            block_new(1:minr,1:minc) = theBlock_cut(1:minr,end-minc+1:end);
        elseif(bottom && left)
            block_new(1:minr,1:minc) = theBlock_cut(end-minr+1:end,1:minc);
        elseif(bottom && right)
            block_new(1:minr,1:minc) = theBlock_cut(end-minr+1:end,end-minc+1:end);
        end        
    end
%     block_new_rot = block_new > 0;
    if(good1 && good2)
        newBlock = block_new;
        newRotBlock = block_new>0;
        return;
    end
    
end

%for i = 1:1:NBlocks
ss = size(theBlock);   % the size of the block.

newBlock = theBlock;
newRotBlock = theRotBlock;

if(max(ss)<=max([nr nc]) && min(ss)<=min([nr nc]))
    okay = 1;
else % this component ! needs to be trimmed
    % i
    rowMarg = sum(theBlock>0,2);
    colMarg = sum(theBlock>0,1);
    %theBlock = Blocks{i};
    %theRotBlock =Rots{i};
    
    %FIGURE OUT THE ORIENTATION:
    % try chopping without
    [totalChopped1,rs1,cs1] = findBestCrop(rowMarg, colMarg, nr,nc); %don't rotate the frame
    [totalChopped2,rs2,cs2] = findBestCrop(rowMarg, colMarg, nc,nr); %rotate the frame
    
    if(totalChopped1>0 && ((totalChopped1<totalChopped2) || (rotFlag==0))  ) % orientation is proper
        % chop the block:
        ss = size(theBlock);
        newBlock = theBlock;
        %             newBlock_bk = theBlock;
        %             newRotBlock_bk = theRotBlock;
        
        newBlock = newBlock(rs1:min(rs1+nr-1,ss(1)), cs1:min(cs1+nc-1,ss(2)));
        newRotBlock = theRotBlock(rs1:min(rs1+nr-1,ss(1)), cs1:min(cs1+nc-1,ss(2)));
        
        %             %% check the opposite side
        %             if(min(rs1+nr-1,ss(1)) ~= size(newBlock_bk,1)) % the opposite side has also been chopped, take case
        %                 good = sum(newBlock_bk > 0,2) == size(newBlock,2);
        %                 good_rr = find(good);
        %                 if(good_rr(end)~=size(newBlock_bk,1))
        %                    temp = sum(sum(newBlock_bk(good_rr(end)+1:end,:) > 0));
        %                    if(isinteger(temp/size(newBlock,2)))
        %                       rnum = temp/size(newBlock,2);
        %                       rlast = good_rr + rnum;
        %                       rst = max(rlast-nr,1);
        %                       newBlock = newBlock_bk(rst:rlast, cs1:min(cs1+nc-1,ss(2)));
        %                       newRotBlock = newRotBlock_bk(rst:rlast, cs1:min(cs1+nc-1,ss(2)));
        %                    end
        %                 end
        %             end
        
        % what pieces were left out of the newBlock?
        % need to make them small again...
        
        
    elseif (totalChopped2>0 && ((totalChopped2<totalChopped1) && (rotFlag==1))) %must allow rotation for this one...
        ss = size(theBlock);
        newBlock = theBlock;
        newBlock = newBlock(rs2:min(rs2+nc-1,ss(1)), cs2:min(cs2+nr-1,ss(2)));
        newRotBlock = theRotBlock(rs2:min(rs2+nc-1,ss(1)), cs2:min(cs2+nr-1,ss(2)));
        
    end
    
    
    
end
%end
end


function [totalChopped, rs, cs] = findBestCrop(rowMarg, colMarg, nr,nc)
% assume rotation is fixed and find the best chop...
% totalChopped is the number of pieces that are chopped.
% rs is the starting row for the row chopping
% cs is the starting col for the col chopping
totalChopped = 0;
totalPieces = sum(rowMarg);
rs = 1;
cs = 1;

% what are the nr connected rows that maximize the chop?
if(numel(rowMarg)>nr) %find best trim for rows
    startR = 1:1:(numel(rowMarg)+1-nr);
    piecesKeptR  = zeros(size(startR));
    for(i = startR)
        piecesKeptR(i) = sum(rowMarg(i:i+nr-1));
    end
    [aa,bbR] = max(piecesKeptR);
    choppedR = totalPieces-aa;
    totalChopped = totalChopped+choppedR;
    rs = bbR;
end
if(numel(colMarg)>nc) %find best trim for cols
    startC = 1:1:(numel(colMarg)+1-nc);
    piecesKeptC  = zeros(size(startC));
    for(i = startC)
        piecesKeptC(i) = sum(colMarg(i:i+nc-1));
    end
    [aa,bbC] = max(piecesKeptC);
    choppedC = totalPieces-aa;
    totalChopped = totalChopped+choppedC;
    cs = bbC;
end


end
