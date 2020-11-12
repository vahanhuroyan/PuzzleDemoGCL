%% Relposition: How two pieces are matched together
%% currentPieceRot: the rotation of the known piece(not the whole to be filled)
%% scoreMat: number of wholes x 4, in the order of ccw rotation number(if rotation is scrambled)
%%           number of wholes x 1(if rotation is known)

function [scoreMat] = getAllScoresForCands_rui(SCO, cands, pieceID, currentPieceRot, Relposition, rotFlag)
% gets the scores from SCO for a set of candidate pieces.
% for fitting against pieceID. PieceID has a current rotation, and the
% relative position of the candidate piece to pieceID is Relposition
%   1   top     of P1 w/ bottom of P2
%   2   right   of P1 w/ left of P2
%   3   bottom  of P1 w/ top of P2
%   4   left    of P1 w/ right of P2
%
%
% This function is used to fill a hole in a puxxle component...

%% counter clock wise case (number of ccw rotation to perform)
table = [1  14 11 8;     
         5  2  15 12;               
         9  6  3 16;         
         13 10 7 4;      
         
         2 15 12 5;
         6 3 16 9;         
         10 7 4 13;
         14 11 8 1;
    
         3 16 9 6;
         7 4 13 10;
         11 8 1 14;         
         15 12 5 2;
         
         4 13 10 7;
         8 1 14 11;
         12 5 2 15;         
         16 9 6 3;
    
    ];

% %% counter clock wise case(number of ccw rotation performed)
% table = [1 8 11 14;     %HOLE IS BELOW a known piece with rotation 1 (upright)
%     13 4 7 10;      %HOLE IS BELOW a known piece with rotation 2 (top is to the left)
%     9 16 3 6;       %HOLE IS BELOW a known piece with rotation 3 (upside down)
%     5 12 15 2;      %HOLE IS BELOW a known piece with rotation 4 (top is to the eight)
%     
%     2 5 12 15;
%     14 1 8 11;
%     10 13 4 7;
%     6 9 16 3;
%     
%     3 6 9 16;
%     15 2 5 12;
%     11 14 1 8;
%     7 10 13 4;
%     
%     4 7 10 13;
%     16 3 6 9;
%     12 15 2 5;
%     8 11 14 1
%     
%     ];

% this table is used to get the correct indexes into the layers of SCO
% each column relates to the rotation needed for the new piece...
%
% swapper = [1 4 3 2]; % if the input is cw, change it to ccw first
swapper = [1 2 3 4]; % change the input to ccw first

index = (Relposition-1)*4 + swapper(max(currentPieceRot,1));

layers = table(index,:);
if(rotFlag==0)
    layers= layers(1);
end

% scoreMat = zeros(numel(cands), 3*rotFlag+1);
% for ii = 1:1:numel(cands)
%     scoreMat(ii,:) = SCO(cands(ii), pieceID, layers);
% end
scoreMat = SCO(cands,pieceID,layers);

end