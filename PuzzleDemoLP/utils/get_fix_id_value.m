%% find the largest four components and fix the positions of four 'center' pieces of these four components

function [fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value)

if(do_replicate)
    
    %% find the biggest block
    block_num = size(BlocksInfo.Blocks,1);
    
    if(block_num < 4)        
       return; 
    end
    
    block_num_list = zeros(block_num,1);
    
    for i = 1:block_num
    
        block = BlocksInfo.Blocks{i};        
        block_piece = block(block>0);
        block_piece = block_piece(:);
        block_num_list(i) = length(block_piece);
        
        %% has to check if this piece doesn't have replicate pieces
        block_piece_all = get_all_ind(block_piece,nr*nc);
        if(length(unique(block_piece_all)) < length(block_piece_all))
            block_num_list(i) = 0;
        end
        
    end
    
    [~,ind] = max(block_num_list);
    max_block = BlocksInfo.Blocks{ind};
    mask = max_block > 0;
    [rr,cc] = find(mask);
    [~,piece_ind] = min(abs(rr-cc));
    piece = max_block(rr(piece_ind),cc(piece_ind));
    
    prob_id = piece+(-3:1:3)*nr*nc;
    mask = (prob_id > 0) & (prob_id < 4*nr*nc + 1);
    prob_id = prob_id(mask);
    fix_id = prob_id;
    fix_id = [fix_id;fix_id+n];
    fix_id = fix_id(:);
    
else
    
    %% if no pieces are replicated, do not need to do anything    
    return;
    
end