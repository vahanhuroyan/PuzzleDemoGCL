% Nov 2011. Andy Gallagher

function [newBlock,newRotBlock] = TrimPuzzle(theBlock, theRotBlock, ap,SCO, nr,nc,rotFlag, locked, givenPieces,v1v2Flag, addLots)
% SHOULD ENFORCE THE SIZE OF THE PUZZLE! ENABLE SEEDING OF THE PIECES? 
% ENFORCE THE no-overlap policy.
% enforce single piece additions?
% Quads first, then singles?
% 
% locked means that I know how big the puzzle is... 
%   Remember, I need a "buffer row" on the top and bottom and left and
%   right. 
%
% givenPieces = []; Indexes of pieces that are in the correct postion 
% to start with. Assumes "locked" aspect ratio... 
%

%    addLots = 0; % instead of iterating, just add singles one after another
                % after the initial QuadGrid is formed. 
%    v1v2Flag = 1; %choose v1 for giving preference to 4surrounded neighbors, etc. 
                % v2 is just the most confidenct. (when adding next single)
%
% GI is the array of indexes
% GR is the array of rotations              
                
       
%for i = 1:1:NBlocks
    ss = size(theBlock);   % the size of the block. 
    
        newBlock = theBlock; 
        newRotBlock = theRotBlock;
        
        
    if(max(ss)<=max([nr nc]) && min(ss)<=min([nr nc]))
        okay = 1; 
    else % this component ! needs to be trimmed
       % i
        rowMarg = sum(theBlock>0,2);
        colMarg = sum(theBlock>0,1);
        %theBlock = Blocks{i}; 
        %theRotBlock =Rots{i}; 
        
        %FIGURE OUT THE ORIENTATION: 
        % try chopping without 
        [totalChopped1,rs1,cs1] = findBestCrop(rowMarg, colMarg, nr,nc); %don't rotate the frame
        [totalChopped2,rs2,cs2] = findBestCrop(rowMarg, colMarg, nc,nr); %rotate the frame
        
        if(totalChopped1>0 && ((totalChopped1<totalChopped2) || (rotFlag==0))  ) % orientation is proper
            % chop the block: 
            ss = size(theBlock); 
            newBlock = theBlock; 
            
            newBlock = newBlock(rs1:min(rs1+nr-1,ss(1)), cs1:min(cs1+nc-1,ss(2))); 
            newRotBlock = theRotBlock(rs1:min(rs1+nr-1,ss(1)), cs1:min(cs1+nc-1,ss(2)));
            
            % what pieces were left out of the newBlock? 
            % need to make them small again... 
            
            
        elseif (totalChopped2>0 && ((totalChopped2<totalChopped1) && (rotFlag==1))) %must allow rotation for this one... 
            ss = size(theBlock); 
            newBlock = theBlock; 
            newBlock = newBlock(rs2:min(rs2+nc-1,ss(1)), cs2:min(cs2+nr-1,ss(2))); 
            newRotBlock = theRotBlock(rs2:min(rs2+nc-1,ss(1)), cs2:min(cs2+nr-1,ss(2)));
          
        end
        
        
        
    end
%end
end


function [totalChopped, rs, cs] = findBestCrop(rowMarg, colMarg, nr,nc)
% assume rotation is fixed and find the best chop... 
% totalChopped is the number of pieces that are chopped. 
% rs is the starting row for the row chopping
% cs is the starting col for the col chopping 
    totalChopped = 0; 
    totalPieces = sum(rowMarg); 
    rs = 1; 
    cs = 1; 
    
    % what are the nr connected rows that maximize the chop? 
    if(numel(rowMarg)>nr) %find best trim for rows
        startR = 1:1:(numel(rowMarg)+1-nr);
        piecesKeptR  = zeros(size(startR)); 
        for(i = startR)
            piecesKeptR(i) = sum(rowMarg(i:i+nr-1));  
        end
        [aa,bbR] = max(piecesKeptR); 
        choppedR = totalPieces-aa;
        totalChopped = totalChopped+choppedR; 
        rs = bbR; 
    end
    if(numel(colMarg)>nc) %find best trim for cols
        startC = 1:1:(numel(colMarg)+1-nc);
        piecesKeptC  = zeros(size(startC)); 
        for(i = startC)
            piecesKeptC(i) = sum(colMarg(i:i+nc-1));  
        end
        [aa,bbC] = max(piecesKeptC); 
        choppedC = totalPieces-aa;
        totalChopped = totalChopped+choppedC;       
        cs = bbC; 
    end
    

end




% %%% JUST LINK EDGES.... ONE AFTER THE NEXT, building multiple pieces. 
% 
% % a flag to trim the built puzzle if it is bigger than the boundary... 
% Trim= locked; 
% 
% Hits =[0 0]; % how many proposed block merges are rejected because of overlap?
%                 
%                 
% %function im = GreedyAssembly(pieces,scores)
% pieces = ap;
% scores=SCO;
% N = numel(ap); %number pieces
% 
% 
% % adjust the score matrix to be normalized. Each a,b score is divided by
% % the second best match (to either A or B) on that side of the piece. This 
% % will need to be changed for other rotations. 
% 
% normSCO = SCO; 
% list = 1:size(SCO,1); 
% 
% mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half. 
% 
% 
% t = 0.000000000000001; 
% % NEED TO SPEED THIS UP A LOT! 
% % Normalize the score matrix so that each element is the ``confidence''
% % of a match. (i.e. P(match| features a b). 
% % for ii = 1:1:size(SCO,3) %over each possible arrangement.
% %     ii
% % for jj = 1:1:size(SCO,1) %over each row. 
% % for kk = 1:1:size(SCO,2) %over each possible arrangement. 
% %     value = SCO(jj,kk,ii); 
% %     n1 = min(SCO( jj, list~=kk,ii)); %best nonsame 
% %     n2 = min(SCO( list~=jj, kk,ii)); 
% %     nval = (value+t)/(min(n1,n2)+t);    % closest match 
% %     normSCO(jj,kk,ii) = nval; 
% % end
% % end
% % end %the easy one to program, but slow
% 
% for ii = 1:1:size(SCO,3) %over each possible arrangement.
%     fprintf('Processing Scores Matrix %d\n',ii);
%     %    ii
%     [aaa,bbb] = sort(SCO(:,:,ii),2); % sorted over each row.
%     rowmins = aaa(:,1:2); %2smallest over each row.
%     rowminloc = bbb(:,1); %location of minimum in each row.
%     
%     [aaa,bbb] = sort(SCO(:,:,ii)); % sorted over each column.
%     colmins = aaa(1:2,:); %2smallest over each row.
%     colminloc = bbb(1,:); %location of minimum in each row.
%     
%     for jj = 1:1:size(SCO,1) %over each row.
%         values = SCO(jj,:,ii);% the values in the row.
%         n1 = values.*0 + rowmins(jj,1); %the minimum for that row...
%         n1(rowminloc) = rowmins(jj,2); % the second lowest
%         %each position can also be replaced by the smallest nonsame value in  the column...
%         n2 = values.*0 + colmins(1,:); %the smallest value in each column.
%         % but whereever the row is the same, we use the second lowest value instead
%         n2(jj==colminloc)= colmins(2,jj==colminloc);
%         nval = (values+t)./(min([n1;n2])+t);
%         normSCO(jj,:,ii) = nval;
%     end
% end
% 
% 
% 
% bknormSCO = normSCO;
% 
% BSize = 0; 
% Blocks = {}; %empty list of blocks for initialization
% Rots =[]; %keep track of the rotation of pieces within the blocks. 
% iters = 1; 
% gogo = 1; 
% 
% %VECTORIZED = normSCO(:);
% 
% ST = 1.25; 
% while gogo
%     
%     
%     %if(floor(iters/500)*500==iters)
%     %    REFRESH=1
%     %    VECTORIZED = normSCO(:);
%     %end
%     % do this in a loop
%     % find the best match from the entire array:
%     %[aa,BB] = min(VECTORIZED); % the most confident remaining match
%     [aa,BB] = min(normSCO(:)); % the most confident remaining match
%     % MAKE SURE THE SAME PIECE IS NOT ADDED TWO TIMES!
%     % this takes about .75 seconds per call.
%     % maybe I could sort once, and then make it faster?
%     
%     
%     
%     
%     
%     if(isnan(aa) || aa>ST )
%         gogo = 0;
%     end
%     
%     
%     %if(aa>.2518)
%     %debugstuff=1
%     
%     %end
%     
%     [R,C,How] = ind2sub(size(normSCO),BB);
%     
%     HowPos = mod((How-1),4)+1;  % the ABSOLUTE rotation of the second piece
%     HowRot = floor((How-1)/4)+1;% the relative positions of the pieces
%     
%     P1 = R; P2 = C;
%     %R and C are the next suggested pieces to join.
%     Rb = R;
%     Cb = C;
%     
%     Rr = 1; Cr = 1;
%     %find what blocks they belong to.
%     rmems = zeros(numel(Blocks),1);
%     cmems = zeros(numel(Blocks),1);
%     findr = [];
%     findc = [];
%     for ii = 1:1:numel(Blocks);
%         rmems(ii)= ismember(R, Blocks{ii});
%         cmems(ii)= ismember(C, Blocks{ii});
%     end
%     if(sum(rmems))
%         findr = find(rmems);
%         Rb = Blocks{findr};
%         Rr = Rots{findr};
%     end
%     if(sum(cmems))
%         findc = find(cmems);
%         Cb = Blocks{findc};
%         Cr = Rots{findc};
%     end
%     
%     if(sum(rmems)>1 ||sum(cmems)>1)
%         danger=1;
%     end
%     % okay, now join the pieces to get a new piece:
%     
%     if(numel(findr==1) && numel(findc==1))
%         if(findr~=findc)
%             [b r  s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
%             BSize = sum(b(:)>0);
%         else
%             s=0; BSize=0;
%         end
%     else
%         [b r s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
%         
%         BSize = sum(b(:)>0);
%     end
%     Hits = Hits+[s==1 s==0];
%     %b
%     if(s==1)
%         % b is the new puzzle piece.
%         if(numel(findr))
%             Blocks{findr} =b;
%             Rots{findr} =r;
%             if(numel(findc))
%                 Blocks{findc} = [];
%                 Rots{findc} =[];
%             end
%         elseif(numel(findc)) %the findr is empty (meaning first piece is a single)
%             Blocks{findc} =b;
%             Rots{findc} =r;
%         else % both pieces were singles.
%             Blocks{end+1} = b;
%             Rots{end+1} =r;
%         end
%         
%         %Blocks{end+1} = b; %this is the new piece.
%         %now, update the SCO matrix for the "taken" pieces.
%         normSCO(P1,:,How) = NaN;
%         normSCO(:,P2,How) = NaN;
%         
%         %HowN = mod(How-1+2,4) +1;
%         HowN  = mirror(How); %get the dual situation...
%         normSCO(P2,:,HowN) = NaN;
%         normSCO(:,P1,HowN) = NaN;
%         
%         
%         %%% Nan out all piecewise combinations of pieces
%         if((numel(Rb)>1)||(numel(Cb)>1))
%             %%%
%             Rb1 = Rb(Rb>0);
%             Cb1 = Cb(Cb>0);
%             
%             for i1 = 1:1:numel(Rb1)
%                 iii1 = Rb1(i1);
%                 for i2 = 1:1:numel(Cb1)
%                     iii2 = Cb1(i2);
%                     normSCO(iii1,iii2,:) = NaN;
%                     normSCO(iii2,iii1,:) = NaN;
%                 end
%             end
%         end
%         % Nan out blocks that
%         
%         %delets the puzzle chunks that were used to form the new one.
%         %    if(numel(findr))
%         %       Blocks{findr} =[];
%         %    end
%         %    if(numel(findc))
%         %        Blocks{findc} = [];
%         %    end
%     else  %unsuccessful match (e.g. pieces actually overlap)
%         %HowN = mod(How-1+2,4) +1;
%         HowN  = mirror(How); %get the dual situation...
%         normSCO(P1,P2,How) = NaN;
%         normSCO(P2,P1,HowN) = NaN;
%         
%     end
%     %VECTORIZED(BB)=NaN;
%     if(BSize> size(normSCO,1)-1)
%         gogo=0;
%     end
%     
%     iters=iters+1;
%     
%     if(floor(iters/100)*100 == iters)
%         fprintf('%d\t%d %d\t%d %d %d %d %d %d %d %d \n',iters,  R ,C ,findr, findc, How, sum(Rb(:)>0), sum(Cb(:)>0), BSize, numel(Blocks), sum(normSCO(:)>0))
%         fprintf('%.2f \n',aa);
%         %[iters  R C findr findc How sum(Rb(:)>0) sum(Cb(:)>0) BSize numel(Blocks) sum(normSCO(:)>0)]
%         
%         %[aa]
%     end
%     
% end
% 
% % find the biggest block. This is the completed puzzle. 
% BlockSize = zeros(numel(Blocks),1);
% for iii = 1:1:numel(Blocks)
%     BlockSize(iii) = sum(Blocks{iii}(:)>0);     
% end
% [aa,bb] = max(BlockSize); 
% GI = Blocks{bb}; 
% GR = Rots{bb}; %the corresponding rotations. 
% 
% % can "derotate" the pieces here... 
% %%% 
% % derotate the pieces: 
%             
% for jj = 1:1:numel(GR)
%     if(GR(jj)>0)
%         rv = GR(jj); 
%         rotateCCW = rv-1; 
%         bid = GI(jj); 
%         ap{bid} = imrotate(ap{bid},90*rotateCCW);
%     end
% end
% 
% [im_,GraphIds] = renderPiecesFromGraphIDs(ap,GI,0);
% %evaluate the puzzle piece fitting together: 
% [Res] = EvalPuzzleAssembly(GraphIds, nc, nr)
% 
% % 
% % 
% % %Find a list of the bidirectional Quads:
% % %[quads1 quadpairs1 quadquality1 correctquads1] = findQuadsFB(SCO,1/.9,1, nr,nc); %make the tolerance 1.1 for forcing to find only quads that are alot better than 2nd best choices.
% % [quads1 quadpairs1 quadquality1 correctquads1] = findQuadsFB(SCO,1/.8,1, nr,nc); %make the tolerance 1.1 for forcing to find only quads that are alot better than 2nd best choices.
% % %quads1=quads1(:,:,1) ; quadpairs1= quadpairs1(1:4,:);quadquality1=quadquality1(1:4);  %to do pure greedy assembly
% % 
% % 
% % %
% % if(nargin<5)
% %     locked = 0; 
% %     givenPieces = []; 
% %     v1v2Flag = 1; 
% % elseif(nargin<6); 
% %     givenPieces = [];     
% %     v1v2Flag = 1; 
% % elseif(nargin<7); 
% %     v1v2Flag = 1; 
% % end
% % if(nargin<8)
% %     addLots=0; %add singles 1 at a time. 
% % end
% % 
% % if(numel(givenPieces))%if some pieces are given
% %     if(sum(givenPieces>0)&& sum(givenPieces<=nr*nc)==numel(givenPieces))
% %         locked = 1; 
% %     else
% %         fprintf('\n\nWARNING: There is an error with the givenPieces.\n\n\n'); 
% %         GraphIds=[]; im_=[]; 
% %         return; 
% %     end
% % end
% % 
% % 
% % %startingGrid 
% % GI=zeros(nr,nc);
% % %lock in the Given Pieces
% % GI(givenPieces) = givenPieces; 
% % %now, pad with extra rows and columns. 
% % gb = zeros(nr+2,nc+2);
% % gb(2:nr+1,2:nc+1)=GI;
% % GI = gb; 
% % 
% % 
% % numInPuz =0; 
% % viewSteps = 0; 
% % cnts = 1; 
% % 
% % while numInPuz<N
% %     if(cnts==12)
% %         qqqqqqq=1; 
% %     end
% %     % build up the starting quadtree: 
% %     %BGI = size(GI); 
% %     [GI,totalModifiedQ,locked] = AddQuadsToGrid(ap,SCO,quads1,GI,locked,nr,nc); %this is the best I can do
% %    % BF = [BGI size(GI)]
% %    % quadInPuz = sum(GI(:)>0)
% % %GI
% %    if(viewSteps && floor(cnts/viewSteps)*viewSteps==cnts)
% %         [im_1,GraphIds1] = renderPiecesFromGraphIDs(ap,GI,0);
% %         imagesc(im_1)
% %         title 'after quads'
% %         pause
% %    end
% %     
% %     % now, add lots of single pieces: 
% %     if(addLots)
% %         grid2 = GI;
% %         totalModified =1; cnt=1;
% %         while(totalModified)
% %         [grid2,totalModified] = AddNextSingle(ap,SCO, grid2,locked,v1v2Flag,nr,nc);
% %         cnt=cnt+1; [cnt sum(grid2(:)>0)];
% %         end
% %         GI = grid2; 
% %     else
% %     %add a single piece
% %     [GI,totalModifiedS,locked] = AddNextSingle(ap,SCO, GI,locked,v1v2Flag,nr,nc);
% %     end
% %     numInPuz = sum(GI(:)>0);
% %     
% %    if(viewSteps && floor(cnts/viewSteps)*viewSteps==cnts)
% %         [im_1,GraphIds1] = renderPiecesFromGraphIDs(ap,GI,0);
% %         imagesc(im_1)
% %         title(strcat('after single',num2str(cnts)));
% %         pause
% %     end
% %     cnts=cnts+1; 
% % end
% % 
% % [im_,GraphIds] = renderPiecesFromGraphIDs(ap,GI,0);
% % %evaluate the puzzle piece fitting together: 
% % [Res] = EvalPuzzleAssembly(GraphIds, nc, nr)
% % 
% % %[quads1 quadpairs1 quadquality1 correctquads1] = findQuadsFB(SCO,1); %make the tolerance 1.1 for forcing to find only quads that are alot better than 2nd best choices.
% % %correctquads tells if the quads are correct or not.
% 
% 
% % % build the connected grid out of only the
% % % start on the top of the quads list;
% % gblock = [];
% % gmems = [];
% % miniblock= quads1(:,2,1);
% % gblock = [miniblock(1) miniblock(2); miniblock(4) miniblock(3)];
% % gmems = gblock(:);
% % % pad with a block of zeros.
% % gblock = [0 0 0 0 ; 0 miniblock(1) miniblock(2) 0 ;0 miniblock(4) miniblock(3) 0; 0 0 0 0 ];
% % 
% % 
% % startpt = 2;
% % keepGoing =1;
% % iters =0;
% % while keepGoing
% % 
% %     iters = iters+1
% % 
% %     keepGoing =0;
% %     % now, start the loop.
% %     for ii = 2:1:size(quads1,3)
% %         %ii = 2;
% %         if(ii ==140)
% %             wwwww =12
% %         end
% % 
% %         miniblock= quads1(:,2,ii);
% %         mblock = [miniblock(1) miniblock(2); miniblock(4) miniblock(3)];
% % 
% % 
% % 
% %         %Are any of these in the gblock?
% %         [anchorPoints,anchorLock] = (ismember(mblock,gblock)); %are any in the grid yet?
% %         % anchorPoints will be 1 when that piece is already present in the puzzle.
% %         % anchorLock tells where.
% %         if(sum(anchorPoints(:))>0)
% %             %the new quad can be added.
% %             % where is the quad in the gblock?
% %             AL = anchorLock;
% %             %find a non-zero member
% %             [iii] = find(AL); % find the position of the
% %             [rrr,ccc] = find(AL); % find the position of the
% %             vvv = AL(iii);
% %             % just use the first nonzero one.
% %             % it is at rrr(1) ccc(1) and maps tp vvv(1)
% %             [rr,cc]=ind2sub(size(gblock), vvv(1)); %this is the position in the big array
% %             %then, to map between the quad to the big one,
% %             %rr-rrr(1)
% % 
% %             targetArea = gblock(rr-rrr(1)+1:rr-rrr(1)+2,cc-ccc(1)+1:cc-ccc(1)+2);
% %             % this is the target area.
% %             % are there any non-zero conflicts?
% %             Conflict =  (targetArea~=mblock).*targetArea;
% %             addsSomething = sum(targetArea(:)>0)<4;
% % 
% %             if(~Conflict & addsSomething) % we can add the piece
% %                 keepGoing = 1;
% %                 gblock(rr-rrr(1)+1:rr-rrr(1)+2,cc-ccc(1)+1:cc-ccc(1)+2) = mblock;
% % 
% %                 %%% add extra rows/columns as necessary...
% %                 vv = sum(gblock);
% %                 hh = sum(gblock,2);
% %                 if(vv(1)~=0)
% %                     %add a column
% %                     gb = [zeros(size(gblock,1),1)   gblock];
% %                     gblock = gb;
% %                 end
% %                 if(vv(end)~=0)
% %                     %add a column
% %                     gb = [ gblock zeros(size(gblock,1),1)];
% %                     gblock = gb;
% %                 end
% %                 if(hh(1)~=0)
% %                     %add a column
% %                     gb = [zeros(1, size(gblock,2));   gblock];
% %                     gblock = gb;
% %                 end
% %                 if(hh(end)~=0)
% %                     %add a column
% %                     gb = [   gblock  ;zeros(1, size(gblock,2))];
% %                     gblock = gb;
% %                 end
% % 
% %             end
% % 
% % 
% %             %     for ii = 1:1:2
% %             %         for jj = 1:1:2
% %             %             al = mblock(ii,jj);
% %             %             gv = gblock(rr -rrr(1)+ii, cc-ccc(1)+jj );
% %             % %            [ii jj al gv]
% %             %
% %             %             gblock(rr -rrr(1)+ii, cc-ccc(1)+jj )=al;
% %             %         end
% %             %     end
% %             %
% % 
% %             %widen the canvas
% %         end
% %     end
% % 
% % 
% % 
% % end  % end of the while loop
% % %we've added all of the quads that can be added...
% % %maybe I should skip the quads that have already been used?
% % 
% % % NOW, NEED TO ADD SINGLE PIECES...
% % 
% % 
% % 
% % 
% % GraphIds = gblock; 
% % return
% % 
% % 
% % www=1
% % www=2
% % 
% % %Assume the size of the puzzle is defined by nr nc
% % %Assume the size of the puzzle is defined.
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % %function im = GreedyAssembly(pieces,scores)
% % %
% % % Do a greedy assembly of a puzzle. 
% % % pieces are 
% % %
% % % pieces: a structure of the puzzle pieces e.g. pieces{3} is 28x28x3
% % % scores: NxNx4 matrix of the cost of having one piece next to another. 
% % %  
% % 
% % % sort all of the pairwise costs: 
% % % Disallow overlaps, 
% % % CONSIDER THE FIT to multiple neighbors? 
% % 
% % N = numel(pieces); 
% % %most confident matches in each diection
% % [aa,aai] = sort(scores(:,:,1),2); %top
% % [bb,bbi] = sort(scores(:,:,2),2); %R
% % [cc,cci] = sort(scores(:,:,3),2); %bot
% % [dd,ddi] = sort(scores(:,:,4),2); %L
% % 
% % aai = aai(:,1); 
% % bbi = bbi(:,1); 
% % cci = cci(:,1); 
% % ddi = ddi(:,1); 
% % 
% % Edgeiness(:,1) = (aa(:,2)+1)./(aa(:,1)+1); %ratio of the closest 2 matches...  
% % Edgeiness(:,2) = (bb(:,2)+1)./(bb(:,1)+1); %ratio of the closest 2 matches...  
% % Edgeiness(:,3) = (cc(:,2)+1)./(cc(:,1)+1); %ratio of the closest 2 matches...  
% % Edgeiness(:,4) = (dd(:,2)+1)./(dd(:,1)+1); %ratio of the closest 2 matches...  
% % %[aa,aai] = min(scores(:,:,1),[],2); %top
% % %[bb,bbi] = min(scores(:,:,2),[],2); %R
% % %[cc,cci] = min(scores(:,:,3),[],2); %bot
% % %[dd,ddi] = min(scores(:,:,4),[],2); %L
% % 
% % 
% % % list them all 
% % allpairs = [[1:N]' aai; [1:N]' bbi; [1:N]' cci; [1:N]' ddi]; 
% % allscores= [Edgeiness(:,1);Edgeiness(:,2);Edgeiness(:,3);Edgeiness(:,4)];
% % relations = [ones(N,1); ones(N,1).*2;ones(N,1).*3;ones(N,1).*4]; 
% % 
% % 
% % % Now, sort them all: 
% % 
% % [A,B] = sort(allscores,'descend'); %B is the sorted List... 
% % %find the best pair
% % 
% % PPP = allpairs(B,:); 
% % allpairs =PPP; 
% % relations = relations(B); 
% % 
% % 
% % B(1)
% % pairs = [];
% % relate = [];
% % 
% % 
% % pairs(1,1:2) = allpairs(B(1),:)
% % relate(1) = relations(B(1)); 
% % List = unique(pairs); % these pieces have been placed in the puzzle
% % usedList = B.*0; 
% % usedList(1) = 1; 
% % 
% % for i=2:1:numel(pieces)*4
% %     i
% %     % find the next piece to add:
% %     Oklist = ismember(allpairs,List);% these pairs are OK
% %     % take the topmost one, that hasn't been included yet
% %     Candidates = sum(Oklist,2)==1; % & (usedList==0);
% %     C = find(Candidates);   % indexes of the candidate pairs in the list of allpairs
% %     
% %     if(isempty(C)) break;end
% %     
% %     useIt = C(1); 
% %     %%% Test whether it is redundant... 
% %     % relation: Mx1 the corresponding spatial relationship (1 2 3 4) between the pair
% % %   1   top     of P1 w/ bottom of P2
% % %   2   right   of P1 w/ left of P2
% % %   3   bottom  of P1 w/ top of P2
% % %   4   left    of P1 w/ right of P2
% % %
% %     pairX = allpairs(useIt,:);              % e.g. pieces 7 14
% %     relX = relations(useIt);                % e.g. 2     (piece 14 to the right of piece 7)
% %     modrelX = mod((relX-1)+2,4)+1;          % 
% %     
% %     % is there already a piece to the right of 7, or a piece to the left of
% %     % 14?
% %     % e.g. 4 things to look for:
% %     % piece 1 in first col
% %     p1i = sum(pairs==pairX(1),2); % rows with piece 7
% %     p2i = sum(pairs==pairX(2),2); % rows with piece 14
% %     pairsX = pairs((p1i+p2i)>0,: ); % all the rows 
% %     relsX  = relate((p1i+p2i)>0);
% %     % when is p1 in position 1? 
% %     p1p1 = pairs(:,1)==pairX(1);
% %     p1p2 = pairs(:,2)==pairX(1);
% %     p2p1 = pairs(:,1)==pairX(2);
% %     p2p2 = pairs(:,2)==pairX(2);
% %     
% %     p1p1R = relate(p1p1);
% %     p1p2R = relate(p1p2);
% %     p2p1R = relate(p2p1);
% %     p2p2R = relate(p2p2);
% %     Dumpit = 0; 
% %     
% %     if(sum(p1p1R==relX)>0)
% %         % already used!
% %         Dumpit = 1; 
% %     elseif(sum(p1p2R==  modrelX)>0)
% %         Dumpit = 1; 
% %     elseif(sum(p2p1R==  modrelX)>0)
% %         Dumpit = 1; 
% %     elseif(sum(p2p2R== relX)>0)
% %         Dumpit = 1; 
% %     end
% %     
% %     if(Dumpit==1)
% %         % get rid of it... 
% %  %       allpairs(useIt,:)=[0 0];              % e.g. pieces 7 14
% %         
% %     else
% %          
% %     
% %     
% %     pairs(i,1:2) = allpairs(useIt,:); 
% %     relate(i) = relations(useIt); 
% %     List = unique(pairs); % these pieces have been placed in the puzzle
% %     usedList(i) = 1; 
% %     
% %       if(mod(i,3)==0)
% %         pairs
% %         relate
% %          [im,GraphIds] = renderPieces(pieces, pairs, relate,3,[20 20]);
% %         imagesc(im);axis image;axis off; 
% %         pause
% %       end
% %       
% %     end
% %     i
% % end
% % 
% % 
% % 
% % end
% % %end
