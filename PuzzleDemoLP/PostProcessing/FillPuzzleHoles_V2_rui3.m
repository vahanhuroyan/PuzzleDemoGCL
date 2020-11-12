% Nov 2011. Andy Gallagher
% do some speedup

function [newBlock,newRotBlock] = FillPuzzleHoles_V2_rui3(Block, Rot, SCO, nr,nc,rotFlag,show,varargin)

[do_replicate,specified_choices] = getPrmDflt(varargin,{'do_replicate',0,'specified_choices',[]}, 1);

% This is a post-processing step.
% the idea is:
%
% Get a block of a mostly done puzzle.
% Then, fill the holes in the puzzle block...
% this is an alternative to the strategy of looking for confident pairs to
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
if(do_replicate)
    choices = specified_choices;
    del_num = length(choices) - 4*(nr*nc-sum(Block(:)>0));
else
    choices = setdiff(1:(nr*nc),Block(:));
    del_num = 0;
end

if(isempty(choices))    
    return;
end

% count existing neighbors
filled = Block>0;
ss = size(Block);
[rr,cc] = find(Block==0);

neiNum = imfilter(uint8(filled), [0 1 0; 1 0 1; 0 1 0]);
ii = sub2ind(size(neiNum), rr,cc);
nn = neiNum(ii);

% determine the next one to sort.
[aa,bb] = sort(nn,'descend');

%         max_neigh = max(aa);
%         test = sum(aa == max_neigh);
test = sum(aa>0);
nei_code_all = cell(test,1);
nei_rot_all = cell(test,1);
nei_ids_all = cell(test,1);
ratio_all = zeros(test,1);
neighScores_all = zeros(numel(choices),3*rotFlag+1, test);

rr_sorted = rr(bb(1:test));
cc_sorted = cc(bb(1:test));

no_pieces = 0;

for W = 1:test
    
    % what is the piece to fill?
    % spot = [rr_sorted(W) cc_sorted(W)];
    % what are the neighbors?
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


failcnt = 0;
failT =10;

gogo = 1;

while gogo
    
    %fill the top spot.
    if(numel(ratio_all)>0 && size(neighScores_all,1)-del_num>0)
        
        [aa,phlist] = sort(ratio_all);
        neighScores = neighScores_all(:,:,phlist(1));
        nei_ids = nei_ids_all{phlist(1)};
        nei_code = nei_code_all{phlist(1)};
        
        %now, get the scores of whole to to filled
        [aa,bb] = sort(neighScores(:)); %smallest to biggest.
        
        gogo =0;
        
        for ii = 1:1:numel(bb)
            
            [iii,jjj] = ind2sub(size(neighScores), bb(ii));
            %iii is the candidate id, jjj is the rotation index
            choice = choices(iii);
            choicerot = jjj;
            choicepos = nei_code(1);
            nei = nei_ids(1);
            
            [b,~,s] = joinPiecesR(choice,newBlock,1,ones(size(newRotBlock)),choice, nei,choicepos);
            r = newRotBlock; r(b ~= newBlock) = choicerot;
           
           
            %                         im = renderPiecesFromGraphIDs(ap,b,0);
            %                         figure
            %                         imshow(im);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %             debug only(highlight the whole to be filled)
            %
            if(show && s)
                
                ap2 = ap;
                for jj = 1:1:numel(b)
                    if(b(jj) > 0)
                        piece = b(jj);
                        rotateCCW = r(jj)-1;
                        ap2{piece} = imrotate(ap{piece},90*rotateCCW);
                    end
                end
                
                figure(1)
                subplot(1,11,[1 5]);
                im = renderPiecesFromGraphIDs(ap2,b,0);
                im_prev = renderPiecesFromGraphIDs(ap2,newBlock,0);
                
                %% Be careful the gt_piece will be different if the image is rotated
                
                gt_piece = find(ppp == find(b ~= newBlock));
                %% flip the row and column
                %             ind = find(b~=newBlock);
                %             [rr,cc] = ind2sub(size(newBlock),ind);
                %             ind = sub2ind(size(newBlock),nr-rr+1,nc-cc+1);
                %             gt_piece = find(ppp == ind);
                im(im~=im_prev)=255;
                imshow(im);
                hold on
                
                %% plot the first five candidates
                
                candnum = min(numel(bb),5);
                toplist = zeros(candnum,1);
                toprot = zeros(candnum,1);
                for tt = 1:candnum
                    [tti,ttj] = ind2sub(size(neighScores), bb(tt));
                    toplist(tt) = tti;
                    cost = neighScores(tti,ttj);
                    toprot(tt) = ttj;
                    subplot(1,11,tt+5);
                    im = ap2{choices(tti)};
                    imshow(im);
                    title(sprintf('piece %d, rot %d, cost %.2f',choices(tti),ttj,cost));
                end
                
                [gt_cost,gt_rot] = min(neighScores(choices == gt_piece,:));
                subplot(1,11,11);
                im = ap2{gt_piece};
                imshow(im);
                title(sprintf('gt %d, rot %d, cost %.2f',gt_piece,gt_rot,gt_cost));
                
                pause;
                clf;
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberHolesBefore = sum(newBlock(:)==0);
            NumberHolesNow = sum(b(:)==0);
            
            if(s && (NumberHolesNow == NumberHolesBefore-1)) %successful (AND PLUGGED HOLE!).
                
                % just update the wholes influneced by the last filled one
                % do not need to reinitialize everything
                fPiece = choices(iii);
                fPiece_all = get_all_ind(fPiece,nr*nc);
                [~,iii_all] = ismember(fPiece_all,choices);
                if(~do_replicate)                   
                    choices = setdiff(choices,fPiece);
                else
                    choices = setdiff(choices,fPiece_all);
                end
                [rr,cc] = find(b ~= newBlock); % find out the position of newly added piece
                
                %% update neighScores_all and ratio_all
                ratio_all(phlist(1)) = [];
                rr_sorted(phlist(1)) = [];
                cc_sorted(phlist(1)) = [];
                neighScores_all(:,:,phlist(1)) = [];
                nei_ids_all(phlist(1)) = [];
                nei_code_all(phlist(1)) = [];
                
                %% have to all four pieces if it is the replication case
                if(~do_replicate)
                    neighScores_all(iii,:,:) = [];
                else
                    neighScores_all(iii_all,:,:) = [];
                end
                
                if(size(neighScores_all,1) == del_num)
                    newBlock=b;
                    newRotBlock=r;
                    gogo = 1;
                    no_pieces = 1;
                    break;
                end
                
                for i = 1:size(neighScores_all,3)                    
                    temp = neighScores_all(:,:,i);
                    aa = sort(temp(:));
                    if(length(aa) > 1)
                        ratio_all(i) = aa(1)/aa(2);
                    else
                        ratio_all(i) = aa;
                    end
                end
                
                listNum = size(neighScores_all,3);
                
                %% check the four possible neighbors of newly added piece
                pos = [-1 0; 0 1; 1 0; 0 -1];
                nei_map = [3 4 1 2];
                
                for kk = 1:4
                    hrr = rr+pos(kk,1);
                    hcc = cc+pos(kk,2);
                    if( hrr > 0 && hcc > 0 && hrr <= ss(1) && hcc <= ss(2) && b(hrr,hcc) == 0)
                        nei_code = nei_map(kk);
                        ind = find(hrr == rr_sorted & hcc == cc_sorted,1);
                        
                        nei_rot = r(b ~= newBlock);
                        scoreMat = getAllScoresForCands_rui(SCO, choices, fPiece, nei_rot, nei_code, rotFlag);
                        
                        if(all(size(ind))) %% this whole is already caculated, just add the cost of newly filled piece
                            neighScores_all(:,:,ind) = scoreMat + neighScores_all(:,:,ind);
                            addInd = ind;
                            nei_ids_all{addInd} = [nei_ids_all{addInd}; fPiece];
                            nei_code_all{addInd} = [nei_code_all{addInd}; nei_code];
                        else
                            %% If this whole is not already included in the to be filled list, add it
                            listNum = listNum + 1;
                            neighScores_all(:,:,listNum) = scoreMat;
                            rr_sorted = [rr_sorted;hrr];
                            cc_sorted = [cc_sorted;hcc];
                            addInd = listNum;
                            nei_ids_all{addInd} = fPiece;
                            nei_code_all{addInd} = nei_code;
                        end
                        
                        neighScores = neighScores_all(:,:,addInd);
                        [aa,bb] = sort(neighScores(:));
                        if(length(aa) > 1)
                            ratio_all(addInd) = aa(1)/aa(2);
                        else
                            ratio_all(addInd) = aa;
                        end
                        
                    end
                end
                
                newBlock=b;
                newRotBlock=r;
                gogo = 1;
                
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