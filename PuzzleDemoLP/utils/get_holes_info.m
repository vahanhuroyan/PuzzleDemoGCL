%% get hole info from Blocks
function Holes = get_holes_info(Blocks,Blocks_Rot,SCO,rotFlag)

n = size(SCO,1); % number of pieces
num = size(Blocks,1);  % number of current blocks

pieces_all = (1:n)';
pieces_left = pieces_all;
pieces_boundary = [];  % possible boundary pieces of the block to be matched
pieces_block = cell(num,1);  % boundary pieces of each block
pieces_label = [];

for i = 1:num
    block = Blocks{i};
    pieces_left = setdiff(pieces_left,unique(block(:)));
    [nr,nc] = size(block);
    if(nr*nc == n)   % correct size
        ppiece = get_possible_piece(block,0);
    else
        ppiece = get_possible_piece(block,1);
    end
    pieces_block{i,1} = ppiece;
    pieces_boundary = [pieces_boundary;ppiece];
    pieces_label = [i*ones(length(ppiece),1);pieces_label];
end

pieces_label = [zeros(length(pieces_left),1);pieces_label];

holes_all = cell(num,1);
holes_scores_all = [];
holes_ratio_all = [];
holes_nei_code_all = [];
holes_nei_rot_all = [];
holes_nei_ids_all = [];
holes_label_all = [];

for i = 1:num
    
    block = Blocks{i};
    block_rot = Blocks_Rot{i};
    
    % compute the information of the holes, nearby neighbors
    [nr,nc] = size(block);
    if(nr*nc == n)   % correct size
        holes = get_possible_neigh(block,block_rot,0);
    else
        holes = get_possible_neigh(block,block_rot,1);
    end
    
    %compute the match scores between each whole and each possible match
    %piece
    pieces = [pieces_left;pieces_boundary];
    pieces_ignore = pieces_block{i,1};
    holes = get_holes_scores(SCO,holes,pieces,pieces_ignore,rotFlag);
    holes_all{i,1} = holes;
    
    holes_nei_code_all = [holes_nei_code_all;holes.block_nei_code];
    holes_nei_rot_all = [holes_nei_rot_all;holes.block_nei_rot];
    holes_nei_ids_all = [holes_nei_ids_all;holes.block_nei_ids];
    holes_scores_all = [holes_scores_all;holes.block_nei_scores];
    holes_ratio_all = [holes_ratio_all;holes.block_nei_ratio];
    
    holes_label_all = [holes_label_all;i*ones(length(holes.block_nei_ratio),1)];
    
end


Holes.holes_nei_code_all = holes_nei_code_all;
Holes.holes_nei_rot_all = holes_nei_rot_all;
Holes.holes_nei_ids_all = holes_nei_ids_all;
Holes.holes_scores_all = holes_scores_all;
Holes.holes_ratio_all = holes_ratio_all;
Holes.holes_label_all = holes_label_all;
Holes.pieces_label = pieces_label;
Holes.pieces = pieces;
