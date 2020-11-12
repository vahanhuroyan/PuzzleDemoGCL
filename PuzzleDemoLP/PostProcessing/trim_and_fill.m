% trim and fill the wholes
% use known puzzle dimension to guide the trimming and filling
% if the image is rotated, rotate it back to proper orientation(but might still be upside down)

function [im,real_goal,real_rot] = trim_and_fill(SCO,real_goal,real_rot,nr,nc,ap,ScrambleRotations,show)

[r,c] = size(real_goal);
if(ScrambleRotations && r > c)
    real_goal = imrotate(real_goal,-90);
    real_rot = imrotate(real_rot,-90);
    real_rot = real_rot+1;
    real_rot(real_rot==1) = 0;
    real_rot(real_rot==5) = 1;
    temp = r; r = c; c = temp;
end

if(r < nr)
    rf = sum(real_goal(1,:) == 0 | real_goal(1,:) < 0);
    rl = sum(real_goal(end,:) == 0 | real_goal(end,:) < 0);
    if(rf > rl)
        real_goal = [zeros(nr-r,c);real_goal];
        real_rot = [zeros(nr-r,c);real_rot];
    else
        real_goal = [real_goal;zeros(nr-r,c)];
        real_rot = [real_rot;zeros(nr-r,c)];
    end
end
r = size(real_goal,1);
if(c < nc)
    cf = sum(real_goal(:,1) == 0 | real_goal(:,1) == 0);
    cl = sum(real_goal(:,end) == 0 | real_goal(:,end) == 0);
    if(cf > cl)
        real_goal = [zeros(r,nc-c) real_goal];
        real_rot = [zeros(r,nc-c) real_rot];
    else
        real_goal = [real_goal zeros(r,nc-c)];
        real_rot = [real_rot zeros(r,nc-c)];
    end
end
G_ = real_goal;
G_(G_<0) = 0;

rot_map = [1 2 3 4];
rot_mask = real_rot==0;
real_rot(rot_mask) = 1;
GR = rot_map(real_rot);
GR(rot_mask) = 0;

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