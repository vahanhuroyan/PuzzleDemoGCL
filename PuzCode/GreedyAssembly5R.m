% Andy Gallagher

function [GraphIds,im_,GR, Res, Hits] = GreedyAssembly5R(ap,SCO, nr,nc)
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


Hits =[0 0]; % how many proposed block merges are rejected because of overlap?


% adjust the score matrix to be normalized. Each a,b score is divided by
% the second best match (to either A or B) on that side of the piece. This 
% will need to be changed for other rotations. 

normSCO = SCO; 

mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half. 


t = 0.000000000000001; 
% NEED TO SPEED THIS UP A LOT! 
% Normalize the score matrix so that each element is the ``confidence''
% of a match. (i.e. P(match| features a b). 
% for ii = 1:1:size(SCO,3) %over each possible arrangement.
%     ii
% for jj = 1:1:size(SCO,1) %over each row. 
% for kk = 1:1:size(SCO,2) %over each possible arrangement. 
%     value = SCO(jj,kk,ii); 
%     n1 = min(SCO( jj, list~=kk,ii)); %best nonsame 
%     n2 = min(SCO( list~=jj, kk,ii)); 
%     nval = (value+t)/(min(n1,n2)+t);    % closest match 
%     normSCO(jj,kk,ii) = nval; 
% end
% end
% end %the easy one to program, but slow

for ii = 1:1:size(SCO,3) %over each possible arrangement.
    fprintf('Processing Scores Matrix %d\n',ii);
    %    ii
    [aaa,bbb] = sort(SCO(:,:,ii),2); % sorted over each row.
    rowmins = aaa(:,1:2); %2smallest over each row.
    rowminloc = bbb(:,1); %location of minimum in each row.
    
    [aaa,bbb] = sort(SCO(:,:,ii)); % sorted over each column.
    colmins = aaa(1:2,:); %2smallest over each row.
    colminloc = bbb(1,:); %location of minimum in each row.
    
    for jj = 1:1:size(SCO,1) %over each row.
        values = SCO(jj,:,ii);% the values in the row.
        n1 = values.*0 + rowmins(jj,1); %the minimum for that row...
        n1(rowminloc) = rowmins(jj,2); % the second lowest
        %each position can also be replaced by the smallest nonsame value in  the column...
        n2 = values.*0 + colmins(1,:); %the smallest value in each column.
        % but whereever the row is the same, we use the second lowest value instead
        n2(jj==colminloc)= colmins(2,jj==colminloc);
        nval = (values+t)./(min([n1;n2])+t);
        normSCO(jj,:,ii) = nval;
    end
end



Blocks = {}; %empty list of blocks for initialization
Rots =[]; %keep track of the rotation of pieces within the blocks. 
iters = 1; 
gogo = 1; 

%VECTORIZED = normSCO(:);

ST = 1.25; %the stopping threshold... 
while gogo
    

    [aa,BB] = min(normSCO(:)); % the most confident remaining match
    
    
    
    
    
    if(isnan(aa) || aa>ST )
        gogo = 0;
    end
    
    
    
    
    [R,C,How] = ind2sub(size(normSCO),BB);
    
    
    P1 = R; P2 = C;
    %R and C are the next suggested pieces to join.
    Rb = R;
    Cb = C;
    
    Rr = 1; Cr = 1;
    %find what blocks they belong to.
    rmems = zeros(numel(Blocks),1);
    cmems = zeros(numel(Blocks),1);
    findr = [];
    findc = [];
    for ii = 1:1:numel(Blocks);
        rmems(ii)= ismember(R, Blocks{ii});
        cmems(ii)= ismember(C, Blocks{ii});
    end
    if(sum(rmems))
        findr = find(rmems);
        Rb = Blocks{findr};
        Rr = Rots{findr};
    end
    if(sum(cmems))
        findc = find(cmems);
        Cb = Blocks{findc};
        Cr = Rots{findc};
    end
    

    % okay, now join the pieces to get a new piece:
    
    if(numel(findr==1) && numel(findc==1))
        if(findr~=findc)
            [b r  s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
            BSize = sum(b(:)>0);
        else
            s=0; BSize=0;
        end
    else
        [b r s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
        
        BSize = sum(b(:)>0);
    end
    Hits = Hits+[s==1 s==0];
    %b
    if(s==1)
        % b is the new puzzle piece.
        if(numel(findr))
            Blocks{findr} =b;
            Rots{findr} =r;
            if(numel(findc))
                Blocks{findc} = [];
                Rots{findc} =[];
            end
        elseif(numel(findc)) %the findr is empty (meaning first piece is a single)
            Blocks{findc} =b;
            Rots{findc} =r;
        else % both pieces were singles.
            Blocks{end+1} = b;
            Rots{end+1} =r;
        end
        
        %Blocks{end+1} = b; %this is the new piece.
        %now, update the SCO matrix for the "taken" pieces.
        normSCO(P1,:,How) = NaN;
        normSCO(:,P2,How) = NaN;
        
        %HowN = mod(How-1+2,4) +1;
        HowN  = mirror(How); %get the dual situation...
        normSCO(P2,:,HowN) = NaN;
        normSCO(:,P1,HowN) = NaN;
        
        
        %%% Nan out all piecewise combinations of pieces
        if((numel(Rb)>1)||(numel(Cb)>1))
            %%%
            Rb1 = Rb(Rb>0);
            Cb1 = Cb(Cb>0);
            
            for i1 = 1:1:numel(Rb1)
                iii1 = Rb1(i1);
                for i2 = 1:1:numel(Cb1)
                    iii2 = Cb1(i2);
                    normSCO(iii1,iii2,:) = NaN;
                    normSCO(iii2,iii1,:) = NaN;
                end
            end
        end
        % Nan out blocks that
        
        %delets the puzzle chunks that were used to form the new one.
        %    if(numel(findr))
        %       Blocks{findr} =[];
        %    end
        %    if(numel(findc))
        %        Blocks{findc} = [];
        %    end
    else  %unsuccessful match (e.g. pieces actually overlap)
        %HowN = mod(How-1+2,4) +1;
        HowN  = mirror(How); %get the dual situation...
        normSCO(P1,P2,How) = NaN;
        normSCO(P2,P1,HowN) = NaN;
        
    end
    %VECTORIZED(BB)=NaN;
    if(BSize> size(normSCO,1)-1)
        gogo=0;
    end
    
    iters=iters+1;
    
    if(floor(iters/100)*100 == iters)
        fprintf('%d\t%d %d\t%d %d %d %d %d %d %d %d \n',iters,  R ,C ,findr, findc, How, sum(Rb(:)>0), sum(Cb(:)>0), BSize, numel(Blocks), sum(normSCO(:)>0))
        fprintf('%.2f \n',aa);
        %[iters  R C findr findc How sum(Rb(:)>0) sum(Cb(:)>0) BSize numel(Blocks) sum(normSCO(:)>0)]
        
        %[aa]
    end
    
end

% find the biggest block. This is the completed puzzle. 
BlockSize = zeros(numel(Blocks),1);
for iii = 1:1:numel(Blocks)
    BlockSize(iii) = sum(Blocks{iii}(:)>0);     
end
[~,bb] = max(BlockSize); 
GI = Blocks{bb}; 
GR = Rots{bb}; %the corresponding rotations. 

% can "derotate" the pieces here... 
%%% 
% derotate the pieces: 
            
for jj = 1:1:numel(GR)
    if(GR(jj)>0)
        rv = GR(jj); 
        rotateCCW = rv-1; 
        bid = GI(jj); 
        ap{bid} = imrotate(ap{bid},90*rotateCCW);
    end
end

[im_,GraphIds] = renderPiecesFromGraphIDs(ap,GI,0);
%evaluate the puzzle piece fitting together: 
[Res] = EvalPuzzleAssembly(GraphIds, nc, nr);
