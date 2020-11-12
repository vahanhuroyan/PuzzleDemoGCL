% trim and fill the wholes
% use known puzzle dimension to guide the trimming and filling
% if the image is rotated, rotate it back to proper orientation(but might still be upside down)

function [im,rank_score,real_goal,real_rot] = trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show)

%% Use Andy Gallagher code to get a single connected component first

SCO_new = SCO_update(SCO,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label);
normSCO = get_normSCO(SCO_new,size(SCO_new,3));

Blocks = BlocksInfo.Blocks;
Rots = BlocksInfo.Blocks_Rot;

[G_,GR] = do_greedy_assembly(Blocks,Rots,normSCO);
% [G_,GR] = do_greedy_assembly_rui(Blocks,Rots,normSCO);
% [G_,GR] = do_greedy_assembly_V2(Blocks,Rots,SCO);

[newBlock,newRotBlock] = TrimPuzzle(G_, GR, ap,SCO, nr,nc,ScrambleRotations);
% [newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui2(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations);
[newBlock_,newRotBlock_] = FillPuzzleHoles_V2_rui3(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations,show);

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

rank_score = get_ranking_score(real_goal,SCO);