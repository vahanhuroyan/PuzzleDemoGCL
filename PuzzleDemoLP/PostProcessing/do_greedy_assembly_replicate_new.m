%% do greedy assembly for the replicate case
%% do all the four possible merging together
function [Blocks,Rots] = do_greedy_assembly_replicate_new(Blocks,Rots,normSCO,num)

Hits =[0 0]; % how many proposed block merges are rejected because of overlap?
mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half.

iters = 1; gogo = 1;

ST = 1.25; %the stopping threshold...

while gogo
    
    [aa,BB] = min(normSCO(:)); % the most confident remaining match
    
    if(isnan(aa) || aa>ST )
        gogo = 0;
    end
    
    [R,C,How] = ind2sub(size(normSCO),BB);
    info_temp = [R C 0 How];
    info_all = get_all_info(info_temp,num);
    
    for tt = 1:4
        
        R = info_all(tt,1);
        C = info_all(tt,2);
        How = info_all(tt,4);
        
        P1 = R; P2 = C; Rb = R; Cb = C;
        Rr = 1; Cr = 1;
        
        %find what blocks they belong to.
        rmems = zeros(numel(Blocks),1);
        cmems = zeros(numel(Blocks),1);
        findr = []; findc = [];
        
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
                %             [b,r,s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
                %             [b,r,s]=joinPiecesR_rui(Rb,Cb,Rr,Cr,R,C,How,normSCO,ST);
                [b,r,s,s2]=joinPiecesR_replicate(Rb,Cb,Rr,Cr,R,C,How,num);
                BSize = sum(b(:)>0);
            else
                s=0; BSize=0; s2 = 1;
            end
        else
            %         [b,r,s]=joinPiecesR(Rb,Cb,Rr,Cr,R,C,How);
            %         [b,r,s]=joinPiecesR_rui(Rb,Cb,Rr,Cr,R,C,How,normSCO,ST);
            [b,r,s,s2]=joinPiecesR_replicate(Rb,Cb,Rr,Cr,R,C,How,num);
            BSize = sum(b(:)>0);
        end
        Hits = Hits+[s==1 s==0];
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
            
            if(~s2)  %% set all the possible matching between these two blocks as NaN
                b1 = Rb(Rb>0);
                b2 = Cb(Cb>0);
                normSCO(b1,b2,HowN) = NaN;
                normSCO(b2,b1,HowN) = NaN;
            end
            
        end
        
    end
    
    if(BSize> size(normSCO,1)/4-1)
        gogo=0;
    end
    
    if(BSize> size(normSCO,1)/4-1 || (iters > 500 && aa >= 1))
        gogo=0;
    end
    
    iters = iters+1;
    
    if(floor(iters/100)*100 == iters)
        fprintf('%d\t%d %d\t%d %d %d %d %d %d %d %d \n',iters,  R ,C ,findr, findc, How, sum(Rb(:)>0), sum(Cb(:)>0), BSize, numel(Blocks), sum(normSCO(:)>0))
        fprintf('%.2f \n',aa);
    end
    
end

%% remove all the empty blocks
block_num = length(Blocks);
block_piece_num_list = zeros(block_num,1);
for i = 1:block_num
    temp = Blocks{i};
    block_piece_num_list(i) = sum(temp(:)>0);
end

Blocks = Blocks(block_piece_num_list>0);
Rots = Rots(block_piece_num_list>0);
block_piece_num_list = block_piece_num_list(block_piece_num_list>0);

[~,ind] = sort(block_piece_num_list,'descend');

if(length(ind) >= 4)
    Blocks = Blocks(ind(1:4));
    Rots = Rots(ind(1:4));
end