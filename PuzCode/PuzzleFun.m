% TAKE APART AN IMAGE
function [pieceMat,allPiece, pieceInfo, puzzleInfo] = PuzzleFun(im,PP, wide_p,high_p)
%im is the input image
%PP is the number of pixels per piece
%wide_p is the number of pieces wide
%high_p is the number of pieces high
%
% The image is squished around a bit to get to the correct aspect ratio
% Should probably crop it instead. 
%
%PuzzleFun(C:\images\june2010\)
%
% OUTPUT: 
% pieceMat: unused, an empty matrix
% allPiece: a structure of all of the puzzle pieces
% pieceInfo: a Nx7 matrix, N is number of pieces. 
%       columns indicate: 
%   1 piece index
%   2 position COLUMN
%   3 position ROW
%   4 index of the piece ABOVE
%   5 index of the piece to the RIGHT
%   6 index of the piece BELOW
%   7 index of the piece to the LEFT
%
%   NaN's in cols 4-7 indicate edge/corner pieces. 
%
% puzzleInfo: not used. 
%
% Andy Gallagher
% July 2010. 
%
%
%addpath c:\research\matlab_bgl
%addpath c:\research\moreGraphFunctions


if(nargin==0)
    im = 'c:\images\june2010\DSC_0976sm.jpg'; 
    PP = 28; 
    wide_p = 20; 
    high_p = 20;
end




if(nargin==2) 
    % must figure out pieces wide and high... 
end
if(nargin==3)
end
if(nargin==4)
    if(isempty(wide_p))
        % figure it out
    end
end

%%%%%%%%%%%%%%%%%%%%LOAD THE IMAGE
    if(numel(im)<1000) %then it is a filename... I hope! 
        im = imread(im);
        %im = imnoise(im,'gaussian', 0, 0.0001);

    else
        im = im; 
    end

    
    
    
    





    
% GET THE CORRECT ASPECT RATIO FOR THE IMAGE
% ASPECT RATIO SHOULD 
    
    s = size(im);  %resize all images to common if necessary
    %find the proper aspect ratio 
    newWide = min(s(2), floor(s(1)/high_p*wide_p) ); %new width... 
    newHigh = min(s(1), floor(s(2)/wide_p*high_p) ); %new height... 
    
    if(newHigh<s(1))
            start = round((s(1)-newHigh)/2)+1;  %crop to the aspect ratio 
            im = im(start:(start+newHigh-1),:,:);
    elseif(newWide<s(2))
            start = round((s(2)-newWide)/2)+1;  %crop to the aspect ratio 
            im = im(:, start:(start+newWide-1),:,:); 
    end
    %im = imresize(im, s0(1:2));
    %now, the image is the correct aspect ratio, 
    %just need to resize to the proper size
    
    
    %OKAY, BREAK UP THE PUZZLE
    pixW = PP*wide_p;
    pixH = PP*high_p;
    [pixH pixW]
    im2 = imresize(im,[pixH,pixW]);
    size(im2)




%figure
%imagesc(im2);axis image; 
%pause

%Now, bust up into pieces.
pcnt = 1; 
N = wide_p*high_p; 
allPiece = cell(N,1); 

for i = 1:1:wide_p
    for j = 1:1:high_p
        % i,J is the piece position
        % pieceNum, position, and neighbors... 
        %
        pose = [pcnt i j ];
        %piece indexes that goes above, right, bottom, and left. 
        above = [i j-1];
        rt =    [i+1 j];
        bot =   [i j+1];
        left =  [i-1 j];
        if(j==1)
            AI = NaN;
        else
            AI = (j-1) + (i-1)*high_p; 
        end
        if(i==wide_p)
            RI = NaN;
        else
            RI = (j) + (i)*high_p; 
        end
        if(j==high_p)
            BI = NaN;
        else
            BI = (j+1) + (i-1)*high_p; 
        end
        if(i==1)
            LI = NaN;
        else
            LI = (j) + (i-2)*high_p; 
        end
        
        
        
        pieceInfo(pcnt,:) = [pose AI RI BI LI]; 
        thePiece = im2(  ((j-1)*PP+1):(j*PP) , ((i-1)*PP+1):(i*PP) , : ); 

        allPiece{pcnt} = thePiece; 
        pcnt = pcnt+1; 
    end
end


pieceMat = [];
