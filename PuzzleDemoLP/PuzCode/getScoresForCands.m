

function [scoreMat] = getAllScoresForCands(SCO, cands, pieceID, currentPieceRot, Relposition, rotFlag)
    %gets the scores from SCO for a set of candidate pieces. 
    % for fitting against pieceID. PieceID has a current rotation, and the
    % relative position of the candidate piece to pieceID is Relposition 
    %   1   top     of P1 w/ bottom of P2
    %   2   right   of P1 w/ left of P2
    %   3   bottom  of P1 w/ top of P2
    %   4   left    of P1 w/ right of P2
    %
    % IN SCO, there can be 4 or 16 layers. 
    % the layers mean:     
    % HowPos = mod((How-1),4)+1;  % the ABSOLUTE rotation of the second piece
    % HowRot = floor((How-1)/4)+1;% the relative positions of the pieces
    %
    % This function is used to fill a hole in a puxxle component... 
    %
    %table
%     table = [   1 16 11 6;  %HOLE IS BELOW a known piece with rotation 1 (upright)
%                 5 4 15 10;  %HOLE IS BELOW a known piece with rotation 2 (top is to the right)
%                 9 8 3 14;   %HOLE IS BELOW a known piece with rotation 3 (upside down)
%                 13 12 7 2;  %HOLE IS BELOW a known piece with rotation 4 (top is to the left)
%                 2 13 12 7;  %Hole is to the left of the piece, which is upright... 
%                 6 1 16 11;  %
%                 10 5 4 15;
%                 14 9 8 3;
%                 3 14 9 8; 
%                 7 2 13 12;
%                 11 6 1 16; 
%                 15 10 5 4; 
%                 4 15 10 5;
%                 8 3 14 9; 
%                 12 7 2 13;
%                 16 11 6 1];
            
            table = [1 8 11 14;
                     5 12 15 2;
                     9 16 3 6;
                     13 4 7 10;

                     2 5 12 15;
                     6 9 16 3;
                     10 13 4 7;
                     14 1 8 11;
                     
                     3 6 9 16;
                     7 10 13 4;
                     11 14 1 8;
                     15 2 5 12;
                     
                     4 7 10 13;
                     8 11 14 1;
                     12 15 2 5; 
                     16 3 6 9;
                     ];
    % this table is used to get the correct indexes into the layers of SCO
    % each column relates to the rotation needed for the new piece... 
    %
%swapper = [1 4 3 2]; 
 swapper = [1 2 3 4]; 
    index = (Relposition-1)*4 + swapper(currentPieceRot); 
    
    layers = table(index,:); 
    if(rotFlag==0)
        layers= layers(1); 
    end
    
    
    scoreMat = zeros(numel(cands), size(SCO,3)); 
    for ii = 1:1:numel(cands)
        for jj = 1:1:numel(layers); 
            scoreMat(ii,:) = SCO(cands(ii), pieceID, layers(jj)); 
        end
    end
    
end

