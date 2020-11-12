
 imlist= 'c:\images\june2010\DSC_1057.JPG';
    
    PP = 28; %pixels in a piece
    nc = 42; %numcolumns
    nr = 28; %numrows
      placementKey = reshape([1:nr*nc], nr,nc); 
      ScramblePositions =1;% 0;%1; 
      ScrambleRotations =1;% 0;%1; 
      
      
      [pieceMat,ap, pi] = PuzzleFun(imlist,PP, nc,nr);
      
        if(ScramblePositions)
         ap2 = ap;
         ppp = randperm(numel(ap)); 
         for iii = 1:1:numel(ppp)
         ap2{iii} = ap{ppp(iii)}; 
         end
         ap=ap2; 
        else
            ppp = 1:numel(ap); 
        end
        if(ScrambleRotations)
            randscram = floor(rand(numel(ap),1)*4)+1; 
            for jj = 1:1:numel(ap)
                ap2{jj} = imrotate(ap{jj},90*(randscram(jj)-1));
            end
        ap=ap2;
        end
      ii=1; 
      % compute PuzzlePiece Atribute
         fprintf('Compute Attributes for Puz: %d\n', ii);
         pieceAttributes = ComputePieceAttributes(ap);  % Need to write this 
         fprintf('Done with Compute Attributes for Puz: %d\n', ii);
         
          fprintf('Compute Pairwise Scores for Puz: %d, Method %d\n', ii,7);
          SCO = ComparePiecePairA_ROT(ap, 7,pieceAttributes,ScrambleRotations);
          fprintf('Done with Score Computation for Puz: %d, Method %d\n', ii,7);
          
          
        % the main assembly part;    
        [G_,i_,GR, R, Hits] = GreedyAssembly5R(ap,SCO, nr,nc);
        
        imagesc(uint8(imrotate(imresize(i_,.4,'Nearest'),180)));axis image;axis off
        print -depsc Y:\monthly\gallagher\before_trimming_1176_28.eps
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% NEW CODE FOR FILLING HOLES
        %%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CHECK THE PUZZLE FOR HOLES AND OVERFLOWS
        holes = sum(G_(:)==0);
        Blocks = G_;           
        [newBlock,newRotBlock] = TrimPuzzle(G_, GR, ap,SCO, nr,nc,ScrambleRotations);
        [newBlock_,newRotBlock_] = FillPuzzleHoles_V2(newBlock, newRotBlock, SCO, nr,nc,ScrambleRotations);
        holesnow = sum(newBlock_(:)==0); 
        if(holesnow~=holes)
            fprintf('Hole Filling: was: %d is: %d \n',holes, holesnow);        
        end
        
        
        GR2 = newRotBlock;
        GI = newBlock;
            clear ap2; 
            ap2 = cell(numel(ap)); 
            ap2{1} = ap{1}; %initialize to prevent problems... 
            for jj = 1:1:numel(GR2)
                if(GR2(jj)>0)
                    rv = GR2(jj); 
                    rotateCCW = rv-1; 
                    bid = GI(jj); 
                    ap2{bid} = imrotate(ap{bid},90*rotateCCW);
                end
            end
          %  [im,GraphIds] = renderPiecesFromGraphIDs(ap2,GI,0);
         [im,GraphIds] = renderPiecesFromGraphIDs(ap2,newBlock,0);
          imagesc(uint8(imrotate(imresize(im,.4,'Nearest'),180)));axis image;axis off
          print -depsc Y:\monthly\gallagher\after_trimming_1176_28.eps        
          

        GR2 = newRotBlock_;
        GI = newBlock_;
            clear ap2; 
            ap2 = cell(numel(ap)); 
            ap2{1} = ap{1}; %initialize to prevent problems... 
            for jj = 1:1:numel(GR2)
                if(GR2(jj)>0)
                    rv = GR2(jj); 
                    rotateCCW = rv-1; 
                    bid = GI(jj); 
                    ap2{bid} = imrotate(ap{bid},90*rotateCCW);
                end
            end
          %  [im,GraphIds] = renderPiecesFromGraphIDs(ap2,GI,0);
         [im,GraphIds] = renderPiecesFromGraphIDs(ap2,newBlock_,0);
          imagesc(uint8(imrotate(imresize(im,.4,'Nearest'),270)));axis image;axis off
          print -depsc Y:\monthly\gallagher\after_filling_1176_28.eps             
          