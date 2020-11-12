%% Greedy Assembly for Multiple Blocks at the same time
% step 1: compute the scores between left pieces and possible locations of
% all candidate blocks
% step 2: select the best one in terms of the ratio(best/second best) and
% join it with the corresponded block
% step 3: in case of joining two blocks, check the consistence between the
% two blocks, if not consistent, just skip
% step 4: update the possible locations and left pieces

function [Blocks,Blocks_Rot] = do_greedy_assembly_V2(Blocks,Blocks_Rot,SCO)

if(size(SCO,3) == 4)
    rotFlag = 0;
else
    rotFlag = 1;
end

failcnt = 0;
failT =10;
gogo = 1;

Holes = get_holes_info(Blocks,Blocks_Rot,SCO,rotFlag);

while(gogo)
    
    %% find the best ratio to deal with    
    ratio = Holes.holes_ratio_all;
    
    if(numel(ratio) > 0)
        
        [val,hind] = min(Holes.holes_ratio_all);
        block_id = Holes.holes_label_all(hind);  % which block to deal with
        
        neigh_scores = Holes.holes_scores_all(hind,:,:);
        if(size(neigh_scores,2) ~= 4)
            neigh_scores = neigh_scores';
        end
        
        [val,sind] = sort(neigh_scores(:));
        
        for go = 1:numel(sind)
            
            [pid,rot] = ind2sub(size(neigh_scores),sind(go)); % which piece and which rotation to deal with?
            piece = Holes.pieces(pid);
            
            nei_code = Holes.holes_nei_code_all{hind};
            nei_ids = Holes.holes_nei_ids_all{hind};
            
            block = Blocks{block_id};
            block_rot = Blocks_Rot{block_id};
            
            %% ready to join the block and the piece
            if(Holes.pieces_label(pid) == 0)
                
                %% I ignore the rotation and plug in the piece to the block and set the rotation of the piece afterwards
                [b,~,s] = joinPiecesR(piece,block,1,ones(size(block_rot)),piece,nei_ids(1),nei_code(1));
                
                %% if the size is the same
                if(s && numel(block) == numel(b))
                    r = block_rot;
                    r(b ~= block) = rot;
                elseif(s && numel(block) ~= numel(b))
                    %% four possibilities
                    [rr,cc] = find(b == piece);
                    r = zeros(size(b));
                    if(rr == 1)
                        r(2:end,:) = block_rot;
                    elseif(rr == size(r,1))
                        r(1:end-1,:) = block_rot;
                    elseif(cc == 1)
                        r(:,2:end) = block_rot;
                    elseif(cc == size(r,2))
                        r(:,1:end-1) = block_rot;
                    end
                    r(rr,cc) = rot;
                elseif(s)
                    failcnt = failcnt+1;
                    if(failcnt>failT)
                        gogo=0;
                    end
                end
                
                block = b;
                block_rot = r;
                
                Blocks{block_id} = block;
                Blocks_Rot{block_id} = block_rot;
                
                Holes = get_holes_info(Blocks,Blocks_Rot,SCO,rotFlag);
                
            else
                
                block_id2 = pieces_label(pid);
                block2 = Blocks{block_id2};
                block2_rot = Blocks_Rot{block_id2};
                
                rot_init = block2_rot(block2 == piece);
                block2 = imrotate(block2,(rot-rot_init)*90);
                R2n = imrotate(block2,(rot-rot_init)*90);
                
                RotToCCW = [1 2 3 4; 2 3 4 1;3 4 1 2;4 1 2 3];
                rtrans = [0;RotToCCW(:,rot-rot_init+1)];
                R2nt = rtrans(R2n+1);
                block2_rot = reshape(R2nt,size(R2n));
                
                [b,~,s] = joinPiecesR(block2,block,ones(size(block2_rot)),ones(size(block_rot)),piece,nei_ids(1),nei_code(1));
                
                if(s)
                    
                    block_piece = block(block>0);
                    block2_piece = block2(block2>0);
                    
                    new_block = b;
                    new_rot = zeros(size(block));
                    for i = 1:length(block_piece)
                        new_rot(new_block==block_piece(i)) = block_rot(block==block_piece(i));
                    end
                    for i = 1:length(block2_piece)
                        new_rot(new_block==block2_piece(i)) = block_rot(block==block2_piece(i));
                    end
                    
                    Blocks{block_id} = new_block;
                    Blocks_Rot{block_id} = new_rot;
                    
                    Holes = get_holes_info(Blocks,Blocks_Rot,SCO,rotFlag);
                    
                else
                    
                    failcnt = failcnt+1;
                    if(failcnt>failT)
                        gogo=0;
                    end
                    
                end
                
            end
            
        end
        
    else
        gogo=0;
    end
    
end

% % % % %
% % % % %
% % % % %
% % % % %
% % % % % %% compare the ratio of the possible locations of all blocks
% % % % % ratio = [];
% % % % % ratio_label = [];
% % % % % for i = 1:num
% % % % %    block_nei_ratio = holes_all{i}.block_nei_ratio;
% % % % %    ratio = [ratio;block_nei_ratio];
% % % % %    ratio_label = [ratio_label;i*ones(length(block_nei_ratio),1)];
% % % % % end
% % % % %
% % % % % [val,ind] = min(ratio);
% % % % % block_id = ratio_label(ind);
% % % % % block = Blocks{block_id};
% % % % % block_rot = Blocks_Rot{block_id};
% % % % %
% % % % % %% find out which hole of the block gives the best ratio
% % % % % holes = holes_all{block_id};
% % % % % block_nei_ratio = holes.block_nei_ratio;
% % % % % block_nei_scores = holes.block_nei_scores;
% % % % % block_nei_ids = holes.block_nei_ids;
% % % % % block_nei_code = holes.block_nei_code;
% % % % %
% % % % % [val,ind] = min(block_nei_ratio);
% % % % % neighScores = block_nei_scores{ind};
% % % % % nei_code = block_nei_code{ind};
% % % % % nei_ids = block_nei_ids{ind};
% % % % % [aa,bb] = sort(neighScores(:));
% % % % % [iii,jjj] = ind2sub(size(neighScores), bb(ii));
% % % % %
% % % % % %iii is the candidate id, jjj is the rotation index
% % % % %
% % % % % choice = pieces(iii);
% % % % % rot = jjj;
% % % % % nbor = nei_code(1);
% % % % % nei_id = nei_ids(1);
% % % % %
% % % % % if(ismember(choice,pieces_left))  %% okay, the match happens between a block and a single piece
% % % % %    [b,~,s] = joinPiecesR(choice,block,1,ones(size(block_rot)),choice,nei_id,nbor);
% % % % %    if(s)
% % % % %       %% update the block
% % % % %       r = block_rot; r(b ~= block) = rot;
% % % % %       Blocks{block_id} = b;
% % % % %       Blocks_Rot{block_id} = r;
% % % % %       %% update left pieces
% % % % %       pieces_left = setdiff(pieces_left,choice);
% % % % %       % compute the information of the holes, nearby neighbors
% % % % %       [nr,nc] = size(b);
% % % % %       if(nr*nc == n)   % correct size
% % % % %           holes = get_possible_neigh(b,r,0);
% % % % %           ppiece = get_possible_piece(b,0);
% % % % %       else
% % % % %           holes = get_possible_neigh(b,r,1);
% % % % %           ppiece = get_possible_piece(b,1);
% % % % %       end
% % % % %
% % % % %       pieces_boundary = setdiff(pieces_boundary,pieces_block{block_id});
% % % % %       pieces_block{block_id} = ppiece;
% % % % %       pieces_boundary = union(pieces_boundary,pieces_block{block_id});
% % % % %       pieces = [pieces_left;pieces_boundary];
% % % % %       pieces_ignore = pieces_block{i,1};
% % % % %       holes = get_holes_scores(holes,pieces,pieces_ignore,rotFlag);
% % % % %       holes_all{block_id} = holes;
% % % % %
% % % % %       %% update the hole scores of each block
% % % % %       for i = 1:num
% % % % %           if(i == block_id)
% % % % %               continue;
% % % % %           else
% % % % %               holes = holes_all{i};
% % % % %               block_nei_scores = holes.block_nei_scores;
% % % % %               block_nei_ratio = holes.block_nei_ratio;
% % % % %               % delete the scores of the piece just used
% % % % %               hole_num = size(block_nei_scores);
% % % % %               for k = 1:hole_num
% % % % %                   neighScores = block_nei_scores{k};
% % % % %                   neighScores(:,pieces == choice) = [];
% % % % %                   [aa,~] = sort(neighScores(:));
% % % % %                   if(length(aa) > 1)
% % % % %                       block_nei_ratio(k) = aa(1)/aa(2);
% % % % %                   else
% % % % %                       block_nei_ratio(k) = aa;
% % % % %                   end
% % % % %               end
% % % % %               holes.block_nei_scores = block_nei_scores;
% % % % %               holes.block_nei_ratio = block_nei_ratio;
% % % % %           end
% % % % %       end
% % % % %    end
% % % % % else %% otherwise, the match happens between two blocks
% % % % %
% % % % % end
% % % % %
% % % % %
% % % % %
