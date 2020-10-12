function [B,R,S] = joinPiecesR(B1,B2,R1,R2,P1,P2,How)
%function [B,R,S] = joinPiecesR(B1,B2,R1,R2,P1,P2,How)
%join two puzzle pieces
%
% B1 is piece 1. an array indicating the indexes of puzzle pieces. 
%      e.g. B1 = [ 1 17;0 4; 0 6] where 0 is an empty placeholder. 
%
% B2 is piece 2.  
% 
% R1 is the associated rotation of each piece in B1; 
% R2 is the associated rotation of each piece in B2; 
% P1 is the index in P1 to join
% P2 is the index in P2 to join
% How is how to join them: 
%   1   top     of P1 w/ bottom of P2
%   2   right   of P1 w/ left of P2
%   3   bottom  of P1 w/ top of P2
%   4   left    of P1 w/ right of P2
%
% Nc Nr are the total cols and rows that are allowed. 
%
% OUTPUT: 
% B = the new block
% R = the new rotations
% S = successful?  
%
% Example: 
%
% B1 = [1 17 4 18; 0 6 0 0]; 
% B2 = [0 0 3 0 ; 2 33 91 0; 11 0 0 0];
% R1 = zeros(size(B1)); % not used yet
% R2 = zeros(size(B2)); % not used yet
% P1    = 6; 
% P2    = 3; 
% How   = 2;
% [B,R,S] = joinPieces(B1,B2,R1,R2,P1,P2,How);
% Handles Rotation as well... 

% check for piece doubles: 
B1nz = B1(:); B1nz = B1nz(B1nz>0); 
B2nz = B2(:); B2nz = B2nz(B2nz>0); 
if(sum(ismember(B1nz(:),B2nz(:))))
    %Aarg, a problem
    %attempt to add a duplicate piece
    
    % EXCEPT ZEROS! 
    
    S =0; 
    R = []; 
    B =[]; 
    return; 
end



CCWToGetTo = [ 0 1 2 3; 3 0 1 2; 2 3 0 1; 1 2 3 0]; 
%this is the number of turns to get from current rotation (row) 
% to the desired rotation (column). 
RotToCW = [1 4 3 2;2 1 4 3;3 2 1 4;4 3 2 1];      
% Row is the current rotation. Column is the number of CLOCKWISE TURNS
% applied (plus 1). 
RotToCCW = [1 2 3 4; 2 3 4 1;3 4 1 2;4 1 2 3];      
% Row is the current rotation. Column is the number of CCW TURNS
% applied (+1).

HowPos = mod((How-1),4)+1;  % the ABSOLUTE rotation of the second piece
HowRot = floor((How-1)/4)+1;% the relative positions of the pieces 


[r1,c1] = find(B1==P1); %where is the first piece?  
[r2,c2] = find(B2==P2); % where is the second piece? 

% This isn't very elegant, but it should work. the idea is to: 
% 1. Rotate the first piece until it is in "proper" orientation. 
% 2. Rotate the second piece until it has the orientation for matching. 
% then, proceed as joinPieces (without R)... 

%piece 1. 
rotnow1 = R1(r1,c1); % the current rotation of the first piece in block 1. 
rotationNeeded= rotnow1-1;     % clockwise turns needed to get back to neutral position. 
% do the array Rotation. 
B1n = imrotate(B1, -90*rotationNeeded);%the rotated block 1.  
R1n = imrotate(R1, -90*rotationNeeded);%the rotated block 1 rotations.
rtrans = [0; RotToCW(:,rotationNeeded+1)];  
R1nt = rtrans(R1n+1); 
R1n = reshape(R1nt,size(R1n)); 
% update all of the rotations in R1. 

%okay, so thios one is all set. 
% piece 2. 
rotnow2 = R2(r2,c2); %the currect rotation of the piece in block 2. 
%get nember of CCW turns
rotationNeeded = CCWToGetTo(rotnow2, HowRot); 
B2n = imrotate(B2, 90*rotationNeeded);%the rotated block 1.  
R2n = imrotate(R2, 90*rotationNeeded);%the rotated block 1 rotations.
rtrans = [0;RotToCCW(:,rotationNeeded+1)]; 
R2nt = rtrans(R2n+1); 
R2n = reshape(R2nt,size(R2n)); 



%%%%%%%%%% NOW, DO THE MERGeing process (also merge over the rotations). 
B1 = B1n; 
B2 = B2n; %start with these... 

[r1,c1] = find(B1==P1); %where is the first piece?  
[r2,c2] = find(B2==P2); % where is the second piece? 

[rr1,cc1] = size(B1); %total size of B1 
[rr2,cc2] = size(B2);  % total size of B2

offsets = [-1 0; 0 1; 1 0; 0 -1]; 
O=  offsets(HowPos,:);
B2KeyptinC1 = [r1 c1]+O; % the address of the piece 2 keypoint in the coords of piece 1. 
C2to1 =  B2KeyptinC1-[r2 c2]; %transform from piece 2 to piece 1 coords: 

%%% now, find the range of piece 2 in the piece 1 coord system: 
UL_B2_in_c1 =  [1 1]+C2to1; 
LR_B2_in_c1 =  size(B2)+C2to1;

allCoords = [1 1; [rr1 cc1]; UL_B2_in_c1 ; LR_B2_in_c1]; 

ranges = [min(allCoords); max(allCoords)];%this is in the space of piece 1.  
B1Offset = [1 1]-ranges(1,:); 
B2Offset = B1Offset+C2to1; 

OutBlockSize =ranges(2,:) +B1Offset; %this is the size of the output block we need;

OutBlock =  zeros(OutBlockSize);
OutBlockR =  zeros(OutBlockSize);

%insert the first piece: 
OutBlock((1:rr1)+B1Offset(1),(1:cc1)+B1Offset(2)) = B1; 
Temp = OutBlock; 
Temp((1:rr2)+B2Offset(1),(1:cc2)+B2Offset(2)) = B2; 
OutBlock(Temp>0) = Temp(Temp>0); 

%Make the R Matrix: insert the first piece: 
OutBlockR((1:rr1)+B1Offset(1),(1:cc1)+B1Offset(2)) = R1n; 
Temp = OutBlockR; 
Temp((1:rr2)+B2Offset(1),(1:cc2)+B2Offset(2)) = R2n; 
OutBlockR(Temp>0) = Temp(Temp>0); 

B = OutBlock; 
R = OutBlockR;% dummy for now
%%% CHECK FOR OVERLAP! 
S = sum(B(:)>0)==(sum(B1(:)>0)+sum(B2(:)>0));
% Maybe there is a faster way to check for overlap? 