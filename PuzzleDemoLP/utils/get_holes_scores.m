%% compute the scores for all the holes to be filled
function holes = get_holes_scores(SCO,holes,pieces,pieces_ignore,rotFlag)

block_nei_code = holes.block_nei_code;
block_nei_rot = holes.block_nei_rot;
block_nei_ids = holes.block_nei_ids;

mask = ismember(pieces,pieces_ignore,'rows');

hole_num = size(block_nei_code,1);
block_nei_ratio = zeros(hole_num,1);
block_nei_scores = zeros(hole_num,numel(pieces),3*rotFlag+1);

for j = 1:hole_num
    
    nei_code = block_nei_code{j};
    nei_rot = block_nei_rot{j};
    nei_ids = block_nei_ids{j};
    totalScores = zeros(numel(pieces),3*rotFlag+1,numel(nei_code));
    for k = 1:1:numel(nei_code)
        scoreMat = getAllScoresForCands_rui(SCO, pieces, nei_ids(k), nei_rot(k), nei_code(k), rotFlag);
        totalScores(:,:,k) = scoreMat;
    end
    neighScores = sum(totalScores,3);
    
    % for pieces to ignore, set the scores to inf
    neighScores(mask,:) = inf;
    block_nei_scores(j,:,:) = neighScores;
    
    [aa,~] = sort(neighScores(:));
    if(length(aa) > 1)
        block_nei_ratio(j) = aa(1)/aa(2);
    else
        block_nei_ratio(j) = aa;
    end
end

holes.block_nei_scores = block_nei_scores;
holes.block_nei_ratio = block_nei_ratio;