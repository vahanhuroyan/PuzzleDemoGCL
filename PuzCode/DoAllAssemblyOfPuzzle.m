function [GI, GR, im, Results] = DoAllAssemblyOfPuzzle(ap,SCO,nr,nc,RotFlag,PositionKey)
%function [GI, GR, im, Results] = DoAllAssemblyOfPuzzle(ap,SCO,nr,nc,RotFlag,PositionKey)
% Assembles a puzzle. 
%
% ap is a structure of puzzle pieces
%
% SCO is the array of pairwise relationships. 
% nr is the number of rows 
% nc is the number of cols of pieces. 
% RotFlag: make it one if you want to solve for rotations as well. 
% PositionKey: each element corresponds to the original piece index
%
% Example: 
% 
% imlist= 'c:\images\june2010\DSC_1009.JPG';
%   
%   PP = 28; %pixels in a piece
%   nc = 30; %numcolumns
%   nr = 20; %numrows
%     placementKey = reshape([1:nr*nc], nr,nc); 
%     ScramblePositions =1;% 0;%1; 
%     ScrambleRotations =1;% 0;%1; 
%     [pieceMat,ap, pi] = PuzzleFun(imlist,PP, nc,nr);
%        % compute PuzzlePiece Atribute
%        fprintf('Compute Attributes for Puz: %d\n', ii);
%        pieceAttributes = ComputePieceAttributes(ap);  % Need to write this 
%        fprintf('Done with Compute Attributes for Puz: %d\n', ii);
%        
%         fprintf('Compute Pairwise Scores for Puz: %d, Method %d\n', ii,7);
%         SCO = ComparePiecePairA_ROT(ap, 7,pieceAttributes,ScrambleRotations);
%         fprintf('Done with Score Computation for Puz: %d, Method %d\n', ii,7);
%    [GI, GR, im, Results] = DoAllAssemblyOfPuzzle(ap,SCO,nr,nc,1);
%    imagesc(im);axis image; 
%
% by Andy Gallagher
    

if(nargin<5) 
    RotFlag = 1; 
    PositionKey = randperm(nr*nc); 
elseif(nargin<6)
    PositionKey = randperm(nr*nc); 
end

        ScrambleRotations=RotFlag; 
        % the main assembly part;    
        [G_,i_,GR] = GreedyAssembly5R(ap,SCO, nr,nc);
        
        imagesc(i_) ; axis image; axis off; 
        title('Puzzle assembly, before trimming and filling'); 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% NEW CODE FOR FILLING HOLES
        %%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CHECK THE PUZZLE FOR HOLES AND OVERFLOWS
        holes = sum(G_(:)==0);
        %Blocks = G_; 
       % B1{1} = G_; %a structure to hold the resuls 
       % R1{1} = R; 
            fprintf('Start Trimming\n');
       
        [newBlock,newRotBlock] = TrimPuzzle(G_, GR, ap,SCO, nr,nc,ScrambleRotations);
        [newBlock_,newRotBlock_] = FillPuzzleHoles_V2(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations);
        holesnow = sum(newBlock_(:)==0); 
        if(holesnow~=holes)
            fprintf('Hole Filling: was: %d is: %d \n',holes, holesnow);
        % did anything change? 
            G_ = newBlock_; 
            GR = newRotBlock_; 
        end
        
        %
        G_safe = G_; 
        G_undo = (G_safe==0); 
        G_safe(G_safe==0) = 1; 
        G_temptemp = PositionKey(G_safe);
        G_temptemp(G_undo) = 0;
        [Results] = EvalPuzzleAssembly(G_temptemp, nc, nr);
        
        
      %  [Results] = EvalPuzzleAssembly(G_, nc, nr);
        if(RotFlag)
            %TurnsCCW = [1 0 3 2]; % number of needed turns. 
           % turnLUT =  [1 2 3 4;
             RotToCCW = [1 2 3 4; 2 3 4 1;3 4 1 2;4 1 2 3];            
            bestCorrect = 0; 
            G_best = G_; 
            R_best = GR; 
            for ii=1:1:4
                lrot =[0 RotToCCW(ii,:)];%the zero is to avoid indexing problems
                G_temp = imrotate(G_, 90*(ii-1));%these are CCW turns
                GR_temp =lrot( imrotate(GR, 90*(ii-1)) +1);
                
                %G_temptemp = PositionKey(G_temp);
                
                G_safe = G_temp; 
                G_undo = (G_safe==0); 
                G_safe(G_safe==0) = 1; 
                G_temptemp = PositionKey(G_safe);
                G_temptemp(G_undo) = 0;
                
                
                
                
                [Res] = EvalPuzzleAssembly(G_temptemp, nc, nr);
                
               % imagesc(G_temp); axis image
               % pause
                if(Res(3)>bestCorrect)
                    G_best = G_temp; 
                    R_best = GR_temp; 
                    bestCorrect = Res(3); 
                    Results = Res; 
                end
            end
        else
            G_best = G_; 
            R_best = GR; 
            
            
        end
        
        
        % assign the output variables. 
        GI =G_best; 
        GR =R_best;
       
       
        
        % RENDER THE IMAGE FOR OUTPUT: 
             % can "derotate" the pieces here... 
            %%% 
            % derotate the pieces: 
            clear ap2; 
            ap2 = cell(numel(ap)); 
            ap2{1} = ap{1}; %initialize to prevent problems... 
            for jj = 1:1:numel(GR)
                if(GR(jj)>0)
                    rv = GR(jj); 
                    rotateCCW = rv-1; 
                    bid = GI(jj); 
                    ap2{bid} = imrotate(ap{bid},90*rotateCCW);
                end
            end
            im = renderPiecesFromGraphIDs(ap2,GI,0);
end

