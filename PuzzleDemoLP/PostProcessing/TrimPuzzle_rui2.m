%%%  Nov 2014, Rui Yu
%%% just use cut_info
function [newBlock,newRotBlock,cut_info] = TrimPuzzle_rui2(theBlock,theRotBlock,ap,SCO,nr,nc,rotFlag,varargin)

[use_boundary,boundary] = getPrmDflt(varargin,{'use_boundary',0,'boundary',[]}, 1);

row_st = 0;
row_end = 0;
col_st = 0;
col_end = 0;

good1 = 0; good2 = 0;
total_pieces = sum(sum(theBlock>0));

theBlock_bk = theBlock;

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
        for i = 1:length(top_piece)
            [top_row,~] = find(theBlock == top_piece(i));
            if(~isempty(top_row))
                break;
            end
        end
        if(~isempty(top_row))
            row_st = top_row;
        else
            warning('top row pieces not founded \n');
        end
%         [top_row,~] = find(theBlock == top_piece(1));
%         row_st = top_row;
    end
    if(bottom)
        bottom_piece = block(end,:);
        bottom_piece = bottom_piece(bottom_piece>0);
        for i = 1:length(bottom_piece)
            [bottom_row,~] = find(theBlock == bottom_piece(i));
            if(~isempty(bottom_row))
                break;
            end
        end
        if(~isempty(bottom_row))
            row_end = bottom_row;
        else
            warning('bottom row pieces not founded \n');
        end
        %         [bottom_row,~] = find(theBlock == bottom_piece(1));
%         row_end = bottom_row;
    end
    % left and right
    if(left)
        left_piece = block(:,1);
        left_piece = left_piece(left_piece>0);
        for i = 1:length(left_piece)
          [~,left_col] = find(theBlock == left_piece(i));
          if(~isempty(left_col))
              break;
          end
        end
        if(~isempty(left_col))
            col_st = left_col;
        else
            warning('left boundary pieces not founded \n');
        end
%         [~,left_col] = find(theBlock == left_piece(1));
%         col_st = left_col;
    end
    if(right)
        right_piece = block(:,end);
        right_piece = right_piece(right_piece>0);
        for i = 1:length(right_piece)
          [~,right_col] = find(theBlock == right_piece(i));
          if(~isempty(right_col))
              break;
          end
        end
        if(~isempty(right_col))
            col_end = right_col;
        else
            warning('right boundary pieces not founded \n');
        end
%         [~,right_col] = find(theBlock == right_piece(1));
%         col_end = right_col;
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

        for i = 1:length(top_piece)
            [top_row,~] = find(theBlock == top_piece(i));
            if(~isempty(top_row))
                break;
            end
        end

%       [top_row,~] = find(theBlock == top_piece(1));
        theBlock_cut(1:top_row-1,:) = [];
        good1 = 1;
    elseif(bottom)
        bottom_piece = block(end,:);
        bottom_piece = bottom_piece(bottom_piece>0);

         for i = 1:length(bottom_piece)
            [bottom_row,~] = find(theBlock == bottom_piece(i));
            if(~isempty(bottom_row))
                break;
            end
        end

%         [bottom_row,~] = find(theBlock == bottom_piece(1));
        theBlock_cut(bottom_row+1:end,:) = [];
        good1 = 1;
    end
    % left and right
    if(left)
        left_piece = block(:,1);
        left_piece = left_piece(left_piece>0);

        for i = 1:length(left_piece)
            [~,left_col] = find(theBlock == left_piece(i));
            if(~isempty(left_col))
                break;
            end
        end

%         [~,left_col] = find(theBlock == left_piece(1));
        theBlock_cut(:,1:left_col-1) = [];
        good2 = 1;
    elseif(right)
        right_piece = block(:,end);
        right_piece = right_piece(right_piece>0);

        for i = 1:length(right_piece)
            [~,right_col] = find(theBlock == right_piece(i));
            if(~isempty(right_col))
                break;
            end
        end

%         [~,right_col] = find(theBlock == right_piece(1));
        theBlock_cut(:,right_col+1:end) = [];
        good2 = 1;
    end

    if(rot == 0)  % proper rotation
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
    block_new_rot = block_new > 0;
    if(good1 && good2)
        newBlock = block_new;
        newRotBlock = block_new_rot;

        if(rot == 1)
            if(col_st == 0 && col_end ~= 0)
                col_st = col_end - nr + 1;
            end
            if(col_st ~= 0 && col_end == 0)
                col_end = col_st + nr - 1;
            end

            if(row_st == 0 && row_end ~= 0)
                row_st = row_end - nc + 1;
            end
            if(row_st ~= 0 && row_end == 0)
                row_end = row_st + nc - 1;
            end
        end

        if(rot == 0)
            if(col_st == 0 && col_end ~= 0)
                col_st = col_end - nc + 1;
            end
            if(col_st ~= 0 && col_end == 0)
                col_end = col_st + nc - 1;
            end

            if(row_st == 0 && row_end ~= 0)
                row_st = row_end - nr + 1;
            end
            if(row_st ~= 0 && row_end == 0)
                row_end = row_st + nr - 1;
            end
        end
        
        row_st = min(row_st,size(theBlock_bk,1));
        row_end = min(row_end,size(theBlock_bk,1));
        col_st = min(col_st,size(theBlock_bk,2));
        col_end = min(col_end,size(theBlock_bk,2));
        
        row_st = max(row_st,1);
        row_end = max(row_end,1);
        col_st = max(col_st,1);
        col_end = max(col_end,1);
        
        cut_info.row_st = row_st;
        cut_info.row_end = row_end;
        cut_info.col_st = col_st;
        cut_info.col_end = col_end;
        
        return;
    end

end

theBlock = theBlock_cut;

%% check filling in result
if((size(theBlock,1) == nr && size(theBlock,2) == nc) || (size(theBlock,1) == nc && size(theBlock,2) == nr))
    newBlock = theBlock;
    newRotBlock = newBlock>1;
end

if(rot == 0)  % proper rotation
    if(top)
       theBlock(nr+1:end,:) = [];
    end
    if(bottom)
       theBlock(1:end-nr,:) = [];
    end
    if(left)
       theBlock(:,nc+1:end) = [];
    end
    if(right)
       theBlock(:,1:end-nc) = [];
    end
    if(~top && ~bottom)
        mask = theBlock>0;
%         [~,good_ind] = max(sum(mask,2));
        good_ind = find(sum(mask,2) == nc);
        if(isempty(good_ind))
           [~,good_ind] = max(sum(mask,2));
        else
           good_ind = good_ind(1);
        end
        mid_ind = good_ind;
%         nrow1 = round(sum(sum(mask(1:mid_ind,:)))/nc);   % divide into two parts from this line
%         nrow2 = round(sum(sum(mask(mid_ind+1:end,:)))/nc);
%         nrow1 = sum(sum(mask(1:mid_ind,:)))/nc;   % divide into two parts from this line
%         nrow2 = sum(sum(mask(mid_ind+1:end,:)))/nc;
        
        total_pieces_r1 = sum(sum(mask(1:mid_ind,:)));
        total_pieces_r2 = total_pieces - total_pieces_r1;
        nrow1 = total_pieces_r1/nc;
        nrow2 = total_pieces_r2/nc;
        
        % what to keep
%         theBlock = theBlock(mid_ind-nrow1+1:mid_ind+nrow2,:);
        row_st = mid_ind-nrow1+1;
        row_end = mid_ind+nrow2;
    end
    if(~left && ~right)
        mask = theBlock>0;
%         [~,good_ind] = max(sum(mask,1));
        good_ind = find(sum(mask,1) == nr);
        if(isempty(good_ind))
           [~,good_ind] = max(sum(mask,1));
        else
           good_ind = good_ind(1);
        end
        mid_ind = good_ind;
%         ncol1 = round(sum(sum(mask(:,1:mid_ind)))/nr);   % divide into two parts from this line
%         ncol2 = round(sum(sum(mask(:,mid_ind+1:end)))/nr);
%         ncol1 = sum(sum(mask(:,1:mid_ind)))/nr;   % divide into two parts from this line
%         ncol2 = sum(sum(mask(:,mid_ind+1:end)))/nr;
        
        total_pieces_c1 = sum(sum(mask(:,1:mid_ind)));
        total_pieces_c2 = total_pieces - total_pieces_c1;
        ncol1 = total_pieces_c1/nr;
        ncol2 = total_pieces_c2/nr;
        
        % what to keep
%         theBlock = theBlock(:,mid_ind-ncol1+1:mid_ind+ncol2);
        col_st = mid_ind-ncol1+1;
        col_end = mid_ind+ncol2;
    end

    if(col_st == 0 && col_end ~= 0)
        col_st = col_end - nc + 1;
    end
    if(col_st ~= 0 && col_end == 0)
        col_end = col_st + nc - 1;
    end

    if(row_st == 0 && row_end ~= 0)
        row_st = row_end - nr + 1;
    end
    if(row_st ~= 0 && row_end == 0)
        row_end = row_st + nr - 1;
    end

end

if(rot == 1)  % wrong rotation

    if(~left && ~right)
        mask = theBlock>0;
        good_ind = find(sum(mask,1) == nc);
        if(isempty(good_ind))
            [~,good_ind] = max(sum(mask,1));
        else
            good_ind = good_ind(1);
        end
        mid_ind = good_ind;
%         ncol1 = round(sum(sum(mask(:,1:mid_ind)))/nc);   % divide into two parts from this line
%         ncol2 = round(sum(sum(mask(:,mid_ind+1:end)))/nc);
%         ncol1 = sum(sum(mask(:,1:mid_ind)))/nc;   % divide into two parts from this line
%         ncol2 = sum(sum(mask(:,mid_ind+1:end)))/nc;
        
        total_pieces_c1 = sum(sum(mask(:,1:mid_ind)));
        total_pieces_c2 = total_pieces - total_pieces_c1;
        ncol1 = total_pieces_c1/nc;
        ncol2 = total_pieces_c2/nc;
        
        % what to keep
%         theBlock = theBlock(:,mid_ind-ncol1+1:mid_ind+ncol2);
        col_st = mid_ind-ncol1+1;
        col_end = mid_ind+ncol2;
    end


    if(~top && ~bottom)
        mask = theBlock>0;
        good_ind = find(sum(mask,2) == nr);
        if(isempty(good_ind))
            [~,good_ind] = max(sum(mask,2));
        else
            good_ind = good_ind(1);
        end
%         [~,good_ind] = max(sum(mask,2));
        mid_ind = good_ind;
%         nrow1 = round(sum(sum(mask(1:mid_ind,:)))/nr);   % divide into two parts from this line
%         nrow2 = round(sum(sum(mask(mid_ind+1:end,:)))/nr);
%         nrow1 = sum(sum(mask(1:mid_ind,:)))/nr;   % divide into two parts from this line
%         nrow2 = sum(sum(mask(mid_ind+1:end,:)))/nr;
        
        total_pieces_r1 = sum(sum(mask(1:mid_ind,:)));
        total_pieces_r2 = total_pieces - total_pieces_r1;
        nrow1 = total_pieces_r1/nr;
        nrow2 = total_pieces_r2/nr;
        
        % what to keep
%         theBlock = theBlock(mid_ind-nrow1+1:mid_ind+nrow2,:);
        row_st = mid_ind-nrow1+1;
        row_end = mid_ind+nrow2;
    end

    if(col_st == 0 && col_end ~= 0)
        col_st = col_end - nr + 1;
    end
    if(col_st ~= 0 && col_end == 0)
        col_end = col_st + nr - 1;
    end

    if(row_st == 0 && row_end ~= 0)
        row_st = row_end - nc + 1;
    end
    if(row_st ~= 0 && row_end == 0)
        row_end = row_st + nc - 1;
    end

end

newBlock = theBlock;
newRotBlock = newBlock>1;

%% make sure it doesn't exceed the dimension of theBlock

row_st = min(row_st,size(theBlock_bk,1));
row_end = min(row_end,size(theBlock_bk,1));
col_st = min(col_st,size(theBlock_bk,2));
col_end = min(col_end,size(theBlock_bk,2));

row_st = max(row_st,1);
row_end = max(row_end,1);
col_st = max(col_st,1);
col_end = max(col_end,1);

cut_info.row_st = row_st;
cut_info.row_end = row_end;
cut_info.col_st = col_st;
cut_info.col_end = col_end;