function [GI,GR] = do_greedy_assembly_rui(Blocks,Rots,normSCO)

failT = 0;
Hits =[0 0]; % how many proposed block merges are rejected because of overlap?
prev_Hits = Hits;
mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half.

iters = 1;
gogo = 1;

%VECTORIZED = normSCO(:);

ST = 1.25; %the stopping threshold...

while gogo
    
    % how many possible combinations left
    
    [aaa,BBB] = sort(normSCO(:));
    aa = aaa(1);
    BB = BBB(1);
    
    %     if(failT == 0)
    %         [aaa,BBB] = sort(normSCO(:));
    %         %         num2try = sum(~isnan(aaa));
    %     end    
%     aa = aaa(failT+1);
%     BB = BBB(failT+1);
    
    if(isnan(aa))
        gogo = 0;
    end
    
    %     [aa,BB] = min(normSCO(:)); % the most confident remaining match
    %     if(isnan(aa) || aa>ST )
    %         gogo = 0;
    %     end
    
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
            [b,r,s,s2]=joinPiecesR_rui(Rb,Cb,Rr,Cr,R,C,How,normSCO,ST);
            BSize = sum(b(:)>0);
        else
            s=0; BSize=0;
        end
    else
        [b,r,s,s2]=joinPiecesR_rui(Rb,Cb,Rr,Cr,R,C,How,normSCO,ST);
        BSize = sum(b(:)>0);
    end
    Hits = Hits+[s==1 s==0];
    %b
    if(s==1 && s2 == 1)
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
        if(s == 0)
            HowN  = mirror(How); %get the dual situation...
            normSCO(P1,P2,How) = NaN;
            normSCO(P2,P1,HowN) = NaN;
        end
        if(s==1 && s2 == 0)
            failT = failT + 1;
            if(failT == 500)
                ST = ST*2;
                failT = 0;
                Hits - prev_Hits
                prev_Hits = Hits;
            end
        end
    end
        
    %VECTORIZED(BB)=NaN;
    if(BSize> size(normSCO,1)-1)
        gogo=0;
    end
    
    iters=iters+1;
    
    if(floor(iters/100)*100 == iters)
        fprintf('%d\t%d %d\t%d %d %d %d %d %d %d %d \n',iters,  R ,C ,findr, findc, How, sum(Rb(:)>0), sum(Cb(:)>0), BSize, numel(Blocks), sum(normSCO(:)>0))
        fprintf('%.2f \n',aa);
        ST
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