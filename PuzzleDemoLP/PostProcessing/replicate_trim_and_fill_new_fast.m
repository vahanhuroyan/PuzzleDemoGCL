%% trim and fill the wholes in the replicate pieces case
% use known puzzle dimension to guide the trimming and filling

function [im,real_goal,real_rot,rank_score,real_goal_bk,real_rot_bk] = replicate_trim_and_fill_new_fast(SCO,Blocks_top,Rots_top,label,nr,nc,ap,ScrambleRotations,show,varargin)

[use_boundary,boundary] = getPrmDflt(varargin,{'use_boudary',0,'boundary',[]}, 1);

%% Use Andy Gallagher code to get a single connected component first

%% check input Blocks if everything is four times replicated
% BlocksInfo = check_replicate(BlocksInfo,nr*nc);

rotFlag = nr*nc~=size(SCO,1);

block_num = size(Blocks_top,1);
block = boundary.block;

use_boundary = 1;
if(isempty(block))
    block_ind = 1;        
    use_boundary = 0;
else
    if(boundary.top)
        block_piece = block(1,:);
    elseif(boundary.bottom)
        block_piece = block(end,:);
    elseif(boundary.left)
        block_piece = block(:,1);
    elseif(boundary.right)
        block_piece = block(:,end);
    else
        block_piece = block(block>0);
    end
    block_piece = block_piece(block_piece>0);
    block_ind = 0;
    if(~isempty(block_piece))
        for i = 1:block_num
            block_i = Blocks_top{i};
            block_i = block_i(block_i>0);
            if(ismember(block_piece(1),block_i))
                block_ind = i;
            end
        end    
    else
        block_ind = 1;
    end
    if(block_ind == 0)
        block_ind = 1;
    end    
end

block_num = 1;
Blocks_new = cell(block_num,1);
Blocks_Rot_new = cell(block_num,1);
block_elem_num = zeros(block_num,1);
Images_top = cell(block_num,1);
% for i = 1:block_num
for i = 1
    G_ = Blocks_top{block_ind};
    GR = Rots_top{block_ind};
    Images_top{i} = get_im_from_block(G_,GR,ap);
    %     [newBlock,newRotBlock] = TrimPuzzle(G_, GR, ap,SCO, nr,nc,rotFlag);
    [newBlock,newRotBlock] = TrimPuzzle_rui(G_, GR, ap,SCO, nr,nc,rotFlag,'use_boundary',use_boundary,'boundary',boundary);
    Blocks_new{i,1} = newBlock;
    Blocks_Rot_new{i,1} = newRotBlock;
    block_elem_num(i) = numel(newBlock(newBlock>0));
end

[~,ind] = sort(block_elem_num,'descend');
ind
size(Blocks_new)
newBlock = Blocks_new{ind(1),1};
newRotBlock = Blocks_Rot_new{ind(1),1};

% take care
%% add zeros paddings
%% add zero paddings to top and bottom, if this block is rotated, to left and right
padding_num = 20;
if(~boundary.top && ~boundary.bottom)  % padding on top
    cc = size(newBlock,2);
    newBlock = [zeros(padding_num,cc);newBlock];
    newRotBlock = [zeros(padding_num,cc);newRotBlock];
    cc = size(newBlock,2);
    newBlock = [newBlock;zeros(padding_num,cc)];
    newRotBlock = [newRotBlock;zeros(padding_num,cc)];
end
% if(~boundary.bottom) % padding on bottom
%     cc = size(newBlock,2);
%     newBlock = [newBlock;zeros(padding_num,cc)];
%     newRotBlock = [newRotBlock;zeros(padding_num,cc)];
% end
if(~boundary.left && ~boundary.right)  % padding on left
    cc = size(newBlock,1);
    newBlock = [zeros(cc,padding_num) newBlock];
    newRotBlock = [zeros(cc,padding_num) newRotBlock];
    cc = size(newBlock,1);
    newBlock = [newBlock zeros(cc,padding_num)];
    newRotBlock = [newRotBlock zeros(cc,padding_num)];
end
% if(~boundary.right)  % padding on right
%     cc = size(newBlock,1);
%     newBlock = [newBlock zeros(cc,padding_num)];
%     newRotBlock = [newRotBlock zeros(cc,padding_num)];
% end

used_pieces = newBlock(newBlock>0);
choices = setdiff((1:size(SCO,1))',get_all_ind(used_pieces,nr*nc));
% [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
%     'do_replicate',1,'specified_choices',choices,'nnfirst',1);
[newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
    'do_replicate',1,'specified_choices',choices,'distfirst',1);

if(~isempty(block))
    [~,~,cut_info] = TrimPuzzle_rui2(newBlock_,newRotBlock_,ap,SCO,nr,nc,rotFlag,'use_boundary',use_boundary,'boundary',boundary);
    % check cut_info, if both row and col are integers, then we are done,
    % else find most close to integers one and try again.
    % if(~isinteger(cut_info.row_st) || ~isinteger(cut_info.col_st))
    if(~(rem(cut_info.row_st,1) == 0) || ~(rem(cut_info.col_st,1) == 0))
        row_diff = max(abs(cut_info.row_st-round(cut_info.row_st)),abs(cut_info.row_end-round(cut_info.row_end)));
        col_diff = max(abs(cut_info.col_st-round(cut_info.col_st)),abs(cut_info.col_end-round(cut_info.col_end)));
        if(boundary.top || boundary.bottom)
            newBlock = newBlock(:,round(cut_info.col_st):round(cut_info.col_end));
            newRotBlock = newRotBlock(:,round(cut_info.col_st):round(cut_info.col_end));       
        elseif(boundary.left || boundary.right)
            newBlock = newBlock(round(cut_info.row_st):round(cut_info.row_end),:);
            newRotBlock = newRotBlock(round(cut_info.row_st):round(cut_info.row_end),:);
        else
            if(row_diff <= col_diff)  % consider row first
                newBlock = newBlock(round(cut_info.row_st):round(cut_info.row_end),:);
                newRotBlock = newRotBlock(round(cut_info.row_st):round(cut_info.row_end),:);
            end
            if(row_diff > col_diff)  % consider row first
                newBlock = newBlock(:,round(cut_info.col_st):round(cut_info.col_end));
                newRotBlock = newRotBlock(:,round(cut_info.col_st):round(cut_info.col_end));
            end
        end
        used_pieces = newBlock(newBlock>0);
        choices = setdiff((1:size(SCO,1))',get_all_ind(used_pieces,nr*nc));
    %     [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
    %         'do_replicate',1,'specified_choices',choices,'nnfirst',1);
        [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
        'do_replicate',1,'specified_choices',choices,'distfirst',1);
        [~,~,cut_info] = TrimPuzzle_rui2(newBlock_,newRotBlock_,ap,SCO,nr,nc,rotFlag,'use_boundary',use_boundary,'boundary',boundary);
        if(row_diff <= col_diff)
            cut_info.col_st = round(cut_info.col_st);
            cut_info.col_end = round(cut_info.col_end);
            cut_info.row_st = 1;
            cut_info.row_end = size(newBlock_,1);
        else
            cut_info.row_st = round(cut_info.row_st);
            cut_info.row_end = round(cut_info.row_end);
            cut_info.col_st = 1;
            cut_info.col_end = size(newBlock_,2);
        end        
    end

    newBlock = newBlock(cut_info.row_st:cut_info.row_end,cut_info.col_st:cut_info.col_end);
    newRotBlock = newRotBlock(cut_info.row_st:cut_info.row_end,cut_info.col_st:cut_info.col_end);

    if(size(newBlock,1) == 1)
        newBlock_ = newBlock;
        newRotBlock_ = newRotBlock;
    else    
        used_pieces = newBlock(newBlock>0);
        choices = setdiff((1:size(SCO,1))',get_all_ind(used_pieces,nr*nc));
        % [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
        %     'do_replicate',1,'specified_choices',choices,'nnfirst',1);
        [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui_new(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
            'do_replicate',1,'specified_choices',choices,'distfirst',1);
    end
    
end
    
real_goal = newBlock_;
real_rot = newRotBlock_;
ap2 = ap;
if(ScrambleRotations)
    for jj = 1:1:numel(real_rot)
        if(real_rot(jj) > 0)
            piece = real_goal(jj);
            rotateCCW = real_rot(jj)-1;
            ap2{piece} = imrotate(ap{piece},90*rotateCCW);
        end
    end
end
%         im = renderPiecesFromGraphIDs(ap,real_goal,0);
im = renderPiecesFromGraphIDs(ap2,real_goal,0);
% imwrite(im,fullfile(save_path,imlist));

%% compute ranking scores of the output solution
rank_score = get_ranking_score(real_goal,SCO);
real_goal_bk = real_goal;
real_rot_bk = real_rot;

%% convert the result to original input
for i = 1:4
    mask = real_goal > (i-1)*nr*nc & real_goal <= i*nr*nc;
    real_goal(mask) = real_goal(mask) - (i-1)*nr*nc;
    real_rot(mask) = i;
end

real_goal = my_crop(real_goal);
real_rot = my_crop(real_rot);

real_goal_bk = my_crop(real_goal_bk);
real_rot_bk = my_crop(real_rot_bk);