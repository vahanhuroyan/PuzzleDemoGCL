%% trim and fill the wholes in the replicate pieces case
% use known puzzle dimension to guide the trimming and filling

function [im,real_goal,real_rot] = replicate_trim_and_fill_fast(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show)

%% Use Andy Gallagher code to get a single connected component first

SCO_new = SCO_update(SCO,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label);
normSCO = get_normSCO(SCO_new,size(SCO_new,3));

Blocks = BlocksInfo.Blocks;
Rots = BlocksInfo.Blocks_Rot;

rotFlag = nr*nc~=size(SCO,1);
%% select possible blocks to form a image, greedy selecting
[Blocks,Rots,normSCO] = blocks_select(Blocks,Rots,nr*nc,normSCO);
[Blocks_top,Rots_top] = do_greedy_assembly_replicate(Blocks,Rots,normSCO,nr*nc);

block_num = size(Blocks_top,1);
Blocks_new = cell(block_num,1);
Blocks_Rot_new = cell(block_num,1);
block_elem_num = zeros(block_num,1);
Images_top = cell(block_num,1);
for i = 1:block_num
    G_ = Blocks_top{i};
    GR = Rots_top{i};
    Images_top{i} = get_im_from_block(G_,GR,ap);
    [newBlock,newRotBlock] = TrimPuzzle(G_, GR, ap,SCO, nr,nc,rotFlag);
%     [newBlock,newRotBlock] = TrimPuzzle_rui(G_, GR, ap,SCO, nr,nc,ScrambleRotations);
    Blocks_new{i,1} = newBlock;
    Blocks_Rot_new{i,1} = newRotBlock;
    block_elem_num(i) = numel(newBlock(newBlock>0));
end

[~,ind] = sort(block_elem_num,'descend');
ind
size(Blocks_new)
newBlock = Blocks_new{ind(1),1};
newRotBlock = Blocks_Rot_new{ind(1),1};

%% add zeros paddings
%% add zero paddings to top and bottom, if this block is rotated, to left and right
padding_num = 20;
if((size(newBlock,1) == nr && size(newBlock,2) == nc) || (size(newBlock,1) == nc && size(newBlock,2) == nr))
    test = 1;
elseif(size(newBlock,1) == nr)      % proper rotation
    cc = size(newBlock,2);
    newBlock = [zeros(padding_num,cc);newBlock;zeros(padding_num,cc)];
    newRotBlock = [zeros(padding_num,cc);newRotBlock;zeros(padding_num,cc)];
elseif(size(newBlock,1) == nc)      % has been rotated
    cc = size(newBlock,1);
    newBlock = [zeros(cc,padding_num) newBlock zeros(cc,padding_num)];
    newRotBlock = [zeros(cc,padding_num) newRotBlock zeros(cc,padding_num)];
else   % having problems, wrong dimension
    cc = size(newBlock,2);
    newBlock = [zeros(padding_num,cc);newBlock;zeros(padding_num,cc)];
    newRotBlock = [zeros(padding_num,cc);newRotBlock;zeros(padding_num,cc)];
    cc = size(newBlock,1);
    newBlock = [zeros(cc,padding_num) newBlock zeros(cc,padding_num)];
    newRotBlock = [zeros(cc,padding_num) newRotBlock zeros(cc,padding_num)];    
end

%% delete repeat pieces
newBlock = del_block_repeat(newBlock,nr*nc);
newRotBlock(newBlock==0) = 0;

used_pieces = newBlock(newBlock>0);
choices = setdiff((1:size(SCO,1))',get_all_ind(used_pieces,nr*nc));
% [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui2(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations);
[newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui3(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
    'do_replicate',1,'specified_choices',choices);

%% check filling in result
if((size(newBlock,1) == nr && size(newBlock,2) == nc) || (size(newBlock,1) == nc && size(newBlock,2) == nr))
    newBlock = newBlock_;
    newRotBlock = newRotBlock_;
elseif(size(newBlock_,2) == nc) % proper rotation
    % check the result of each row
%     mask = newBlock_>0;
%     good_ind = find(sum(mask,2) == nc);
%     mid_ind = good_ind(1);
%     nrow1 = sum(sum(mask(1:mid_ind,:)))/nc;   % divide into two parts from this line
%     nrow2 = sum(sum(mask(mid_ind+1:end,:)))/nc;
%     % what to keep
%     newBlock = newBlock_(mid_ind-nrow1+1:mid_ind+nrow2,:);
%     newRotBlock = newRotBlock_(mid_ind-nrow1+1:mid_ind+nrow2,:);
    
    mask = newBlock_>0;
    [val,good_ind] = max(sum(mask,2));
    mid_ind = good_ind;
    nrow1 = round(sum(sum(mask(1:mid_ind,:)))/nc);   % divide into two parts from this line
    nrow2 = round(sum(sum(mask(mid_ind+1:end,:)))/nc);
    % what to keep
    newBlock = newBlock_(mid_ind-nrow1+1:mid_ind+nrow2,:);
    newRotBlock = newRotBlock_(mid_ind-nrow1+1:mid_ind+nrow2,:);
    
elseif(size(newBlock_,1) == nc) % wrong rotation
    
%     mask = newBlock_>0;
%     good_ind = find(sum(mask,1) == nc);
%     mid_ind = good_ind(1);
%     ncol1 = sum(sum(mask(:,1:mid_ind)))/nc;   % divide into two parts from this line
%     ncol2 = sum(sum(mask(:,mid_ind+1:end)))/nc;
%     % what to keep
%     newBlock = newBlock_(:,mid_ind-ncol1+1:mid_ind+ncol2);
%     newRotBlock = newRotBlock_(:,mid_ind-ncol1+1:mid_ind+ncol2);
    
    mask = newBlock_>0;
    [val,good_ind] = max(sum(mask,1));
    mid_ind = good_ind;
    ncol1 = round(sum(sum(mask(:,1:mid_ind)))/nc);   % divide into two parts from this line
    ncol2 = round(sum(sum(mask(:,mid_ind+1:end)))/nc);
    % what to keep
    newBlock = newBlock_(:,mid_ind-ncol1+1:mid_ind+ncol2);
    newRotBlock = newRotBlock_(:,mid_ind-ncol1+1:mid_ind+ncol2);
    
else % having problems, wrong dimension
    
    mask = newBlock_>0;
    [val1,good_ind1] = max(sum(mask,1));
    [val2,good_ind2] = max(sum(mask,2));
    
    if(val2 > val1) % nc is 2nd dimesion
        indc = 2;
        nc_good = good_ind2;
        nr_good = good_ind1;        
    else
        indc = 1;        
        nc_good = good_ind1;
        nr_good = good_ind2;
    end
    
    if(indc == 1)
        mid_indc = nc_good;
        ncol1 = round(sum(sum(mask(:,1:mid_indc)))/nc);   % divide into two parts from this line
        ncol2 = round(sum(sum(mask(:,mid_indc+1:end)))/nc);        
        mid_indr = nr_good;
        nrow1 = round(sum(sum(mask(1:mid_indr,:)))/nr); % divide into two parts from this line
        nrow2 = round(sum(sum(mask(mid_indr+1:end,:)))/nr);        
        newBlock = newBlock_(mid_indr-nrow1+1:mid_indr+nrow2,mid_indc-ncol1+1:mid_indc+ncol2);
        newRotBlock = newRotBlock_(mid_indr-nrow1+1:mid_indr+nrow2,mid_indc-ncol1+1:mid_indc+ncol2);
    else
        mid_indc = nc_good;
        ncol1 = round(sum(sum(mask(1:mid_indc,:)))/nc);   % divide into two parts from this line
        ncol2 = round(sum(sum(mask(mid_indc+1:end,:)))/nc);
        mid_indr = nr_good;
        nrow1 = round(sum(sum(mask(:,1:mid_indr)))/nr); % divide into two parts from this line
        nrow2 = round(sum(sum(mask(:,mid_indr+1:end)))/nr);
        newBlock = newBlock_(mid_indc-ncol1+1:mid_indc+ncol2,mid_indr-nrow1+1:mid_indr+nrow2);
        newRotBlock = newRotBlock_(mid_indc-ncol1+1:mid_indc+ncol2,mid_indr-nrow1+1:mid_indr+nrow2);        
    end
    
end

%%
used_pieces = newBlock(newBlock>0);
choices = setdiff((1:size(SCO,1))',get_all_ind(used_pieces,nr*nc));
% [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui2(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations);
[newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui3(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show, ...
                                                    'do_replicate',1,'specified_choices',choices);

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

%% convert the result to original input
for i = 1:4
    mask = real_goal > (i-1)*nr*nc & real_goal <= i*nr*nc;
    real_goal(mask) = real_goal(mask) - (i-1)*nr*nc;
    real_rot(mask) = i;
end