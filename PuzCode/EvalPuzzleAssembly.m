function [scores] = EvalPuzzleAssembly(GraphIDs, Wide, High)
%function [scores] = EvalPuzzleAssembly(GraphIDs, Wide, High)
% 
% This function provides a performance score for a puzzle. 
%
%
%  If we start to handle orientations, then we will have to have to add an
%  argument for the orientation of each puzzle piece as well!

scoreAbs = 0; 
PerfectComponent = 0; 
CorrectPairwise = 0; 


if (nargin==3)
    % align the upper left pixels. 
    
    Car = reshape(1:(Wide*High),[High,Wide]);
    
    minR = min(size(Car,1), size(GraphIDs,1)); 
    minC = min(size(Car,2), size(GraphIDs,2)); 

    Car_ = Car(1:minR,1:minC); 
    GID_ = GraphIDs(1:minR,1:minC); 
    scoreAbs = sum(Car_(:)==GID_(:)); % the number that are absolutely in the correct position. 
    
    
    %%% Evaluate Neighbor Matches: 
    % For every adjacent pair of pieces in the completed puzzle, 
    % how many are actually correct? 
    % Car
    rec_V= false(size(GraphIDs,1)-1, size(GraphIDs,2)); 
    rec_H= false(size(GraphIDs,1),   size(GraphIDs,2)-1); 
    
    t = 0; 
    for i = 1:1:(size(GraphIDs,1)-1)%row
    for j = 1:1:(size(GraphIDs,2))%column
        %Is there a v pair?
        Hp = GraphIDs(i:i+1,j); 
        % are they matches? 
        % search for a match among the real one... 
        [aa1,bb1] = find(Car==Hp(1)); %position of 1 
        [aa2,bb2] = find(Car==Hp(2)); %position of 2
        isHMatch = ((aa1+1==aa2) & (bb1==bb2));
        if(isHMatch) 
            t = t+1; 
            rec_V(i,j) = true;
            % ALIGN THE GraphIDS with the Car image... 
            % i,j in GraphIDS aligns with aa1,bb1 in Car; 
            % 
       %     gid = max([1, aa1-i,i-aa1] )  ; 
       %     gid = max([1, aa1-i,i-aa1] )  ; 
       %     cid = []; 
            
        end
    end
    end
    for i = 1:1:(size(GraphIDs,1))%row
    for j = 1:1:(size(GraphIDs,2)-1)%column
        %is there a h pair? 
        Vp = GraphIDs(i,j:j+1); 
         % search for a match among the real one... 
        [aa1,bb1] = find(Car==Vp(1)); %position of 1 
        [aa2,bb2] = find(Car==Vp(2)); %position of 2
        isVMatch = ((aa1==aa2) &( bb1+1==bb2));
        
        if(isVMatch)
            t=t+1; 
            rec_H(i,j) = true;

        end
%
    end
    end
%    t
    CorrectPairwise = t;
    
    
    
    
    %% find largest correct component
    % Do a connected component search?
    flagarray = GraphIDs.*0; 
    
    PC = 1; 
    cnt = 0; 
    blobsize = 0; 
    Mblobsize = 0; 
    %   find a correct pair: (if none exist, then PC =1.  
    for i = 1:1:(size(GraphIDs,1))%row
    for j = 1:1:(size(GraphIDs,2))%column
        position = [i j]; 

        % Find a possible pix
        if(GraphIDs(i,j)>0  && flagarray(i,j)==0)  % add to the stack
            stack_ =[[i,j]]; 
            cnt=1; 
%            stack_ =[];
            blobsize = 1; 
            
            while(cnt>0)
                [blobsize,cnt,stack_,flagarray] = getNeighbors(blobsize, cnt,stack_, GraphIDs, flagarray, Car); 
                %stack_
            end

            if(blobsize>Mblobsize) Mblobsize =blobsize ;
            end

            
        end
        
        
        
        
    end
    end
    
    t = 0; 
    
end


scores = [scoreAbs CorrectPairwise Mblobsize];
end


function [blobsize cnt stac flagarray]= getNeighbors(blobsize, cnt,stac, GraphIDs, flagarray, Car)
        position = stac(cnt,:); 
        stac =stac(1:cnt-1,:); 
        
        cnt = cnt-1; % this is the pointer
        
        
        i = position(1); 
        j = position(2); 
        flagarray(i,j) = 1; 
        
        
        
        isVMatch = false; 
        isV2Match =false; 
        isHMatch = false; 
        isH2Match =false; 
       

        %is there a h pair? 
        if(j+1<= size(GraphIDs,2))
        Vp = GraphIDs(i,j:j+1); 
         % search for a match among the real one... 
        [aa1,bb1] = find(Car==Vp(1)); %position of 1 
        [aa2,bb2] = find(Car==Vp(2)); %position of 2
        isVMatch = ((aa1==aa2) &( bb1+1==bb2)  & flagarray(i,j+1)==0);
        end
                
        %Is there a v pair?
       if(i+1<= size(GraphIDs,1))

        Hp = GraphIDs(i:i+1,j); 
        % are they matches? 
        % search for a match among the real one... 
        [aa1,bb1] = find(Car==Hp(1)); %position of 1 
        [aa2,bb2] = find(Car==Hp(2)); %position of 2
        isHMatch = ((aa1+1==aa2) & (bb1==bb2)& flagarray(i+1,j)==0);
       end
        
        if(j>1)
        %is there a h pair? 
        V2p = GraphIDs(i,j-1:j); 
         % search for a match among the real one... 
        [aa1,bb1] = find(Car==V2p(1)); %position of 1 
        [aa2,bb2] = find(Car==V2p(2)); %position of 2
        isV2Match = ((aa1==aa2) &( bb1+1==bb2)& flagarray(i,j-1)==0);
        end
        
        
        if(i>1)
        %Is there a v pair?
        H2p = GraphIDs(i-1:i,j); 
        % are they matches? 
        % search for a match among the real one... 
        [aa1,bb1] = find(Car==H2p(1)); %position of 1 
        [aa2,bb2] = find(Car==H2p(2)); %position of 2
        isH2Match = ((aa1+1==aa2) & (bb1==bb2)& flagarray(i-1,j)==0 );
        end
        
        
        % so, for this pixel, I have 2 possible options: 
        if(isVMatch)
            stac = [stac;[i,j+1]];
            cnt=cnt+1;
            blobsize=blobsize+1; 
            flagarray(i,j+1) = 1; 
        end
        if(isHMatch)
            stac = [stac;[i+1,j]];
            cnt=cnt+1;
            blobsize=blobsize+1; 
            flagarray(i+1,j) = 1; 
        end
        if(isV2Match)
            stac = [stac;[i,j-1]];
            cnt=cnt+1;
            blobsize=blobsize+1; 
            flagarray(i,j-1) = 1; 
        end
        if(isH2Match)
            stac = [stac;[i-1,j]];
            cnt=cnt+1;
            blobsize=blobsize+1; 
            flagarray(i-1,j) = 1; 

        end
        
      %  imagesc(flagarray)
%        pause
        
%
end

