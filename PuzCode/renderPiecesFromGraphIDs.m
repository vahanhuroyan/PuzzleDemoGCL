function [im,GraphIDs] = renderPiecesFromGraphIDs(pieces,GraphIDs ,gap,N)
%function [im,GraphIDs] = renderPiecesFromGraphIDs(pieces,graphIDs ,gap,N)
%
% This function makes a rendered image out of the pairs of pieces
%
%
% pieces: a structure of the puzzle pieces e.g. pieces{3} is 28x28x3
%
% pair:   Mx2 pairs of puzzle pieces that are thought to be adjacent
% relation: Mx1 the corresponding spatial relationship (1 2 3 4) between the pair
%   1   top     of P1 w/ bottom of P2
%   2   right   of P1 w/ left of P2
%   3   bottom  of P1 w/ top of P2
%   4   left    of P1 w/ right of P2
%
% gap: White Pixels between even piece
% N is 1x2 the dimensions of the puzzle
%
% im: the output image, ready for display with: 
%imagesc(im); axis image;axis off; 
%
%
%
%
%
%the image is a subgraph of a grid-graph
%
%

im=[];
PP =size(pieces{1},1); % ASSUME SQUARE PIECES


% define a graph as having 
% GraphIDs= zeros(2*N(1)+1,2*N(2)+1,'int16'); % start empty
% % NEED TO DO A WALK IN THE GRAPH. 
% pos = [N(1)+1 N(2)+1]; % this is where to start. 
% 
% GraphIDs(pos(1),pos(2))= pair(1,1); %okay, 1 piece is placed
% newpos = poseLUT(pos,relation(1),1);% forward... 
% GraphIDs(newpos(1),newpos(2) )= pair(1,2);
% 
% usedPairFlag = zeros(size(pair,1),1); 
% usedPairFlag(1) = 1; 
% 
% % now, the main loop! 
%  quitFlag = 0; 
% while(quitFlag ==0)
%     for i = 2:1:size(pair,1)  %for each pair
%        % i
%         quitFlag = 1; 
%         P = pair(i,:);
%         
%         if(sum(P==108))
%         wwwww=1;
%         end
%         [aa,bb] = find(GraphIDs==P(1));
%         % is the first one in the current Puzzle Layout?
%         if(~isempty(aa)  &&(usedPairFlag(i)==0))
%             %part1= 1;
%             quitFlag =0; %don't quit!
%             usedPairFlag(i) = 1; % don't do this one again. 
%             newpos = poseLUT([aa bb], relation(i), 1);
%             GraphIDs(newpos(1),newpos(2)) = P(1,2); 
%         else
%             
%             % look for the second one... 
%             [aa,bb] = find(GraphIDs==P(2));
%             % is the second one in the current Puzzle Layout?
%             if(~isempty(aa)  &&usedPairFlag(i)==0)
%              %   part1=2;
%                 quitFlag =0 ;%don't quit!
%                 usedPairFlag(i) = 1; % don't do this one again. 
%                 theR = relation(i);
%                 newpos = poseLUT([aa bb], relation(i), 2);
%                 GraphIDs(newpos(1),newpos(2)) = P(1,1); 
%             end
%         end
%        % GraphIDs
%     end
% end

%%%% OKAY< NOW THE LAYOUT IS COMPLETE!
GraphIDs;
% NOW, trim 
ccc = sum(GraphIDs,1);
rrr = sum(GraphIDs,2);
%keep any rows or columns execp leading or trailing zeros. 
colz = ccc==0; %1 for the columns that are all zeros. 
rowz = rrr==0; % 1 for the rows that are all zeros. 

colz2 = colz.*0; rowz2 = rowz.*0; 
flag = 0; 
for ii = 1:1:numel(colz); 
   if(flag==0 && colz(ii))
       colz2(ii) = colz(ii); 
   else
       flag=1;
   end
end
flag =0; 
for ii= numel(colz):-1:1; 
   if(flag==0 && colz(ii))
       colz2(ii) = colz(ii); 
   else
       flag=1;
   end
end
flag =0;
for ii = 1:1:numel(rowz); 
   if(flag==0 && rowz(ii))
       rowz2(ii) = rowz(ii); 
   else
       flag=1;
   end
end
flag =0;
for ii = numel(rowz):-1:1; 
   if(flag==0 && rowz(ii))
       rowz2(ii) = rowz(ii); 
   else
       flag=1;
   end
end

%GraphIDs = GraphIDs(~rowz2,:);
%GraphIDs = GraphIDs(:,~colz2);


mode = 1; 
if(mode)
    if(rrr(1)==0 && rrr(end)==0)
        GraphIDs = GraphIDs(2:end-1,:);
    end
    if(ccc(1)==0 && ccc(end)==0)
        GraphIDs = GraphIDs(:,2:end-1);
    end
    
else
    %%%% OR< JUST GET RID OF 1st and LAST
    GraphIDs = GraphIDs(2:end-1,:);
    GraphIDs = GraphIDs(:,2:end-1);
end

%
%GraphIDs = GraphIDs(sum(GraphIDs,2)>0,:);
%GraphIDs = GraphIDs(:, sum(GraphIDs,1)>0);

% Now Render the pieces: 
gridsize = size(GraphIDs); 
im = zeros(gridsize(1)*PP+(gridsize(1)-1)*gap, gridsize(2)*PP+(gridsize(2)-1)*gap,3,'uint8'); 

if(strcmp(class(pieces{1}),'uint16'))

  for ii= 1:1:size(GraphIDs,1)
  for jj= 1:1:size(GraphIDs,2)
      ID = GraphIDs(ii,jj);
      
      if(ID>0)
          thePiece = pieces{ID};
          locR = (ii-1)*(PP+gap)+1:(ii*PP+gap*(ii-1));
          locC = (jj-1)*(PP+gap)+1:(jj*PP+gap*(jj-1));

            for i = 1:1:3
                
                im(locR,locC,i) = thePiece(:,:,i)./(65535/255);       
            end
      end
  end
  end
else%uint8
    
  for ii= 1:1:size(GraphIDs,1)
  for jj= 1:1:size(GraphIDs,2)
      ID = GraphIDs(ii,jj);
      
      if(ID>0)
          thePiece = pieces{ID};
          locR = (ii-1)*(PP+gap)+1:(ii*PP+gap*(ii-1));
          locC = (jj-1)*(PP+gap)+1:(jj*PP+gap*(jj-1));

            for i = 1:1:3
            %   mm=[ max(locR(:)) min(locR(:)) max(locC(:)) min(locC(:)) i ID]
             %  thePiece
                im(locR,locC,i) = thePiece(:,:,i);       
            end
      end
  end
  end
end
  





end

function newpos = poseLUT(pos, relation, forwardFlag)
if(forwardFlag==1)
    if(relation==1)
        newpos = [pos(1)-1 pos(2)];
    elseif(relation==2)
        newpos = [pos(1) pos(2)+1];
    elseif(relation==3)
        newpos = [pos(1)+1 pos(2)];
    else
        newpos = [pos(1) pos(2)-1];
    end
else
    if(relation==1)
        newpos = [pos(1)+1 pos(2)];
    elseif(relation==2)
        newpos = [pos(1) pos(2)-1];
    elseif(relation==3)
        newpos = [pos(1)-1 pos(2)];
    else
        newpos = [pos(1) pos(2)+1];
    end 
end
end



