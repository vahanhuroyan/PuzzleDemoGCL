% Nov 2011. Andy Gallagher

function [newBlock,newRotBlock] = FillPuzzleHoles_V2_rui2(Block, Rot, SCO, nr,nc,rotFlag, locked, givenPieces,v1v2Flag, addLots)
% This is a post-processing step.
% the idea is:
%
% Get a block of a mostly done puzzle.
% Then, fill the holes in the puzzle block...
% this is an alternative to the strategy of looking for comfident pairs to
% match.
%
%
% Note: This assumes a rectangular puzzle.
%
%
% find all of the holes in the block.
% In this version. We fill the holes with a simple method.
%

global ap
global ppp

if(nargin<6)
    rotFlag = 1;
end

newBlock = Block;
newRotBlock = Rot;

% which pieces are NOT in the puzzle already?
choices = setdiff(1:(nr*nc),Block(:));
% count existing neighbors
filled = Block>0;
ss = size(Block);
neiNum = imfilter(uint8(filled), [0 1 0; 1 0 1; 0 1 0]);
[rr,cc] = find(Block==0);

ii = sub2ind(size(neiNum), rr,cc);
nn = neiNum(ii);

% determine the next one to sort.
[aa,bb] = sort(nn,'descend');
ii_sorted = ii(bb); %gives the location of the hole to fill.
rr_sorted = rr(bb);
cc_sorted = cc(bb);

rr_sorted = rr_sorted(aa>0);
cc_sorted = cc_sorted(aa>0);

failcnt = 0;
failT =10;

gogo = 1;
while gogo
    
    %fill  the top spot.
    if(numel(bb)>0)
        
        %         max_neigh = max(aa);
        %         test = sum(aa == max_neigh);
        test = sum(aa>0);
        nei_code_all = cell(test,1);
        nei_rot_all = cell(test,1);
        nei_ids_all = cell(test,1);
        ratio_all = zeros(test,1);
        neighScores_all = zeros(numel(choices),3*rotFlag+1, test);
        
        for W = 1:test
            
            spot = [rr_sorted(W) cc_sorted(W)];
            %what are the neighbors?
            neighbors = [rr_sorted(W)-1 cc_sorted(W);
                rr_sorted(W) cc_sorted(W)-1;
                rr_sorted(W) cc_sorted(W)+1;
                rr_sorted(W)+1 cc_sorted(W);];
            nei_code = [ 1;4;2;3];
            %position of the neighbor, relative to the hole (hole is piece 1).
            %   1   top     of P1 w/ bottom of P2
            %   2   right   of P1 w/ left of P2
            %   3   bottom  of P1 w/ top of P2
            %   4   left    of P1 w/ right of P2
            %
            %make sure to keep out edge spots:
            good = neighbors(:,1)>0 & neighbors(:,2)>0 &neighbors(:,1)<=ss(1)&neighbors(:,2)<=ss(2);
            neighbors = neighbors(good,:);
            nei_code = nei_code(good);
            
            neighbors_i = sub2ind(size(neiNum), neighbors(:,1),neighbors(:,2)); %
            %   neighborsThere = filled(neighbors_i);
            %  neighbors = neighbors(good,:); %these are the neighbors.
            %  nei_code = nei_code(good);
            
            nei_ids = newBlock(neighbors_i);% This is who lives nearby
            nei_rot = newRotBlock(neighbors_i);% This is the current rotation of the pieces.
            good = nei_ids>0;  %only consider neighbors that are occupied.
            
            nei_ids = nei_ids(good);
            nei_rot = nei_rot(good);
            nei_code = nei_code(good);
            neighbors = neighbors(good,:);
            
            %okay, now, for each neighbor, find the best piece not in the assembled
            %puzzle...
            % each hole can be filled with a candidate in any orientation...
            % so there are 4X cands to consider...
            % so, I need the piece BELOW code 1, to the RT of code 2, ABOVE code
            % 3, and to the LEFT of code 4...
            
            if(numel(neighbors>0))
                
                totalScores = zeros(numel(choices),3*rotFlag+1, numel(neighbors(:,1)));
                
                T1 = 1000000000;
                bestSoFar = T1;
                for ii = 1:1:numel(neighbors(:,1))
                    [scoreMat] = getAllScoresForCands_rui(SCO, choices, nei_ids(ii), nei_rot(ii), nei_code(ii), rotFlag);
                    totalScores(:,:,ii) = scoreMat;
                end
                
                neighScores = sum(totalScores,3);
                
            end
            
            nei_ids_all{W} = nei_ids;
            nei_code_all{W} = nei_code;
            nei_rot_all{W} = nei_rot;
            neighScores_all(:,:,W) = neighScores;
            
            [aa,bb] = sort(neighScores(:));
            if(length(aa) > 1)
                ratio_all(W) = aa(1)/aa(2);
            else
                ratio_all(W) = aa;
            end
        end
        
        [aa,bb] = sort(ratio_all);
        neighScores = neighScores_all(:,:,bb(1));
        nei_ids = nei_ids_all{bb(1)};
        nei_code = nei_code_all{bb(1)};
        
        %now, make a sorted list of all of the possibilities...
        [aa,bb] =sort(neighScores(:)); %smallest to biggest.
        
        gogo =0;
        for ii = 1:1:numel(bb)
            
            %try filling in order...
            [iii,jjj] = ind2sub(size(neighScores), bb(ii));
            %iii is the candidate id, jjj is the p[osition index
            choice = choices(iii);
            rot_map = [1 4 3 2];
            choicerot = rot_map(jjj);
            choicepos = nei_code(1);
            nei = nei_ids(1);
            
            [b,~,s] = joinPiecesR(choice,newBlock,1,ones(size(newRotBlock)),choice, nei,choicepos);
            r = newRotBlock; r(b ~= newBlock) = choicerot;
            
            %             im = renderPiecesFromGraphIDs(ap,b,0);
            %             figure
            %             imshow(im);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %             debug only(highlight the whole to be filled)
%             %
%                         ap2 = ap;
%                         for jj = 1:1:numel(b)
%                             if(b(jj) > 0)
%                                 piece = b(jj);
%                                 rotateCCW = r(jj)-1;
%                                 ap2{piece} = imrotate(ap{piece},90*rotateCCW);
%                             end
%                         end
%             
%                         figure(1)
%                         subplot(1,11,[1 5]);
%                         im = renderPiecesFromGraphIDs(ap2,b,0);
%                         im_prev = renderPiecesFromGraphIDs(ap2,newBlock,0);
%             
%                         %% Be careful the gt_piece will be different if the image is rotated
%             
%                         gt_piece = find(ppp == find(b ~= newBlock));
%                         %% flip the row and column
%             %             ind = find(b~=newBlock);
%             %             [rr,cc] = ind2sub(size(newBlock),ind);
%             %             ind = sub2ind(size(newBlock),nr-rr+1,nc-cc+1);
%             %             gt_piece = find(ppp == ind);
%                         im(im~=im_prev)=255;
%                         imshow(im);
%                         hold on
%             
%                         %% plot the first five candidates
%             
%                         candnum = min(numel(bb),5);
%                         toplist = zeros(candnum,1);
%                         toprot = zeros(candnum,1);
%                         for tt = 1:candnum
%                            [tti,ttj] = ind2sub(size(neighScores), bb(tt));
%                            toplist(tt) = tti;
%                            cost = neighScores(tti,ttj);
%                            ttj = rot_map(ttj);
%                            toprot(tt) = ttj;
%                            subplot(1,11,tt+5);
%                            im = ap2{choices(tti)};
%                            imshow(im);
%                            title(sprintf('piece %d, rot %d, cost %.2f',choices(tti),ttj,cost));
%                         end
%             
%                         [gt_cost,gt_rot] = min(neighScores(choices == gt_piece,:));
%                         gt_rot = rot_map(gt_rot);
%                         subplot(1,11,11);
%                         im = ap2{gt_piece};
%                         imshow(im);
%                         title(sprintf('gt %d, rot %d, cost %.2f',gt_piece,gt_rot,gt_cost));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberHolesBefore = sum(newBlock(:)==0);            
            NumberHolesNow = sum(b(:)==0);
            
            if(s && (NumberHolesNow == NumberHolesBefore-1)) %successful (AND PLUGGED HOLE!).
                newBlock=b;
                newRotBlock=r;
                gogo = 1;
                
                % reinitialize everything...
                % are there more holes?
                % which pieces are NOT in the puzzle already?
                choices = setdiff(1:(nr*nc),newBlock(:));
                % count existing neighbors
                filled = newBlock>0;
                ss = size(newBlock);
                neiNum = imfilter(uint8(filled), [0 1 0; 1 0 1; 0 1 0]);
                [rr,cc] = find(newBlock==0);
                
                ii = sub2ind(size(neiNum), rr,cc);
                nn = neiNum(ii);
                
                % determine the next one to sort.
                [aa,bb] = sort(nn,'descend');
                ii_sorted = ii(bb); %gives the location of the hole to fill.
                rr_sorted = rr(bb);
                cc_sorted = cc(bb);
                
                rr_sorted = rr_sorted(aa>0);
                cc_sorted = cc_sorted(aa>0);
                
                break;
            else
                failcnt = failcnt+1;
                if(failcnt>failT)
                    gogo=0;
                end
            end
            
        end
        
    else
        gogo =0;
    end
end
end