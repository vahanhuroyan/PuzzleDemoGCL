function imframe = makeFrameImage(Blocks,Rots,ap)
% make a frame for demoing the process of puzzle assembly. 
% 

Gap = 15; 
Margin = 5; 
AddSingles = 1; 
Trim = 1; 

N = numel(ap); %the total number of frames. 

nn = ceil(sqrt(N)+Margin); 
Grid = zeros(nn); 

P = size(ap{1},1);%the size of each puzzle piece. 

%imarray = cell(numel(Blocks)); 
allp = []; 
for i =1:1:numel(Blocks)
    allp = [allp; Blocks{i}(:)];
end  
%what pieces are NOT there 
if(AddSingles)
   missing = setdiff(1:N,allp); 
   
   cnt = numel(Blocks); 
   for i = 1:1:numel(missing)
       Blocks{cnt+i} = missing(i); 
       Rots{cnt+i} = 1; 
   end
   
   
end




%now, just lay out these images


% just find the next smallest location that will take it

imframe = zeros(Gap*(nn+1)+nn*P,Gap*(nn+1)+nn*P,3); % this is the blank canvas. 

%place pieces one at a time onto empty pieces. 
bs = zeros(1,numel(Blocks)); 
for i =1:1:numel(Blocks); 
    bs(i) = prod(size(Blocks{i})); 
end

[aa,bb] = sort(bs,'descend'); %
for X = 1:1:numel(Blocks)
   i = bb(X);
   %get the piece
   piece = Blocks{i}; 
   ps = size(piece); 
   
   %find the first opening big enough for this piece... 
   flag = 0; 
   
   if(numel(piece)>0)
       imarray = RenderImageWithRotArray(Blocks{i},Rots{i},ap);

       for ii = 1:1:(nn-ps(1)+1)
          for jj = 1:1:(nn-ps(2)+1)
              %
    %          [ii (ii+ps(1)-1) jj (jj+ps(2)-1)]
              checkblock = Grid(ii:(ii+ps(1)-1),jj:(jj+ps(2)-1)); 
              if(sum(checkblock(:))==0 & flag ==0)  %good, stick the piece here... 
                  flag = 1; 
                  Grid(ii:ii+ps(1)-1,jj:jj+ps(2)-1) =1; 
%                  Grid(ii:ii+ps(1)-1,jj:jj+ps(2)-1) =Blocks{i}; %makes a slightly more compact 
                  st_row = Gap+1+(ii-1)*(Gap+P); 
                  st_col = Gap+1+(jj-1)*(Gap+P);

                  end_row = st_row-1+size(imarray,1); 
                  end_col = st_col-1+size(imarray,2); 
                  imframe(st_row:end_row,st_col:end_col,1:3) = imarray; 
              end

          end
       end
   end
    
end
if(Trim==1 )
    across = sum(imframe(:,:,2)>0,2); 
    down = sum(imframe(:,:,2)>0,1);
    
    lastRow = find(across); 
    lastCol = find(down); 
    if(size(lastRow,1)>0 &&size(lastCol,1)>0)
    lastRow = lastRow(end); 
    
    lastCol = lastCol(end)
    imframe = imframe(1:min((lastRow+Gap),size(imframe,1)),1:min((lastCol+Gap),size(imframe,2)),1:3); 
    end
end
