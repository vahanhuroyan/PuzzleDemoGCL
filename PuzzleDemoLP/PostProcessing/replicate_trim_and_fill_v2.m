%% trim and fill the wholes in the replicate pieces case
% use known puzzle dimension to guide the trimming and filling

function [im,real_goal,real_rot] = replicate_trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show)

%% Use Andy Gallagher code to get a single connected component first

SCO_new = SCO_update(SCO,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label);
normSCO = get_normSCO(SCO_new,size(SCO_new,3));

Blocks = BlocksInfo.Blocks;
Rots = BlocksInfo.Blocks_Rot;

rotFlag = nr*nc~=size(SCO,1);

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