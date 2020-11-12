%% return three different cases of Blocks_top

function [Blocks_top_list,Rots_top_list] = get_AssemblyBlocks(SCO,BlocksInfo,label,nr,nc,varargin)

mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]'; %what is the symmetry? %this will cut processing time in half.

[boundary,speed_up] = getPrmDflt(varargin,{'boundary',[],'speed_up',0}, 1);

SCO_new = SCO_update(SCO,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label);

Blocks_top_list = cell(4,1);
Rots_top_list = cell(4,1);

Blocks = BlocksInfo.Blocks;
Rots = BlocksInfo.Blocks_Rot;

%% check if we can do something clever using boundary info

%% do nothing
normSCO = get_normSCO(SCO_new,size(SCO_new,3));
[Blocks_top,Rots_top] = do_greedy_assembly_replicate_new(Blocks,Rots,normSCO,nr*nc);
Blocks_top_list{1} = Blocks_top;
Rots_top_list{1} = Rots_top;

clear normSCO Blocks_top Rots_top

if(speed_up || isempty(boundary.block))
    
    Blocks_top_list{2} = Blocks_top_list{1};
    Rots_top_list{2} = Rots_top_list{1};
    Blocks_top_list{3} = Blocks_top_list{1};
    Rots_top_list{3} = Rots_top_list{1};
    Blocks_top_list{4} = Blocks_top_list{1};
    Rots_top_list{4} = Rots_top_list{1};
    
else
    
    %% do top & bottom
    SCO_new_temp = SCO_new;
    block = boundary.block;
    block_top = block(1,:);
    block_bottom = block(end,:);
    block_top = block_top(block_top>0);
    block_bottom = block_bottom(block_bottom>0);
    info_p1 = [block_top(:);block_bottom(:)];
    info_p4 = [ones(length(block_top(:)),1);3*ones(length(block_bottom(:)),1)];
    info_temp = [info_p1 ones(size(info_p1)) zeros(size(info_p1)) info_p4];
    info_temp_all = get_all_info(info_temp,nr*nc);
    for i = 1:size(info_temp_all,1)
        SCO_new_temp(info_temp_all(i,1),:,info_temp_all(i,4)) = inf;
        SCO_new_temp(:,info_temp_all(i,1),mirror(info_temp_all(i,4))) = inf;
    end
    normSCO = get_normSCO(SCO_new_temp,size(SCO_new_temp,3));
    [Blocks_top,Rots_top] = do_greedy_assembly_replicate_new(Blocks,Rots,normSCO,nr*nc);
    Blocks_top_list{2} = Blocks_top;
    Rots_top_list{2} = Rots_top;    
    clear normSCO Blocks_top Rots_top
    
    %% do left & right
    SCO_new_temp = SCO_new;
    block = boundary.block;
    block_left = block(:,1);
    block_right = block(:,end);
    block_left = block_left(block_left>0);
    block_right = block_right(block_right>0);
    info_p1 = [block_left(:);block_right(:)];
    info_p4 = [ones(length(block_left(:)),1)*4;2*ones(length(block_right(:)),1)];
    info_temp = [info_p1 ones(size(info_p1)) zeros(size(info_p1)) info_p4];
    info_temp_all = get_all_info(info_temp,nr*nc);
    for i = 1:size(info_temp_all,1)
        SCO_new_temp(info_temp_all(i,1),:,info_temp_all(i,4)) = inf;
        SCO_new_temp(:,info_temp_all(i,1),mirror(info_temp_all(i,4))) = inf;
    end
    normSCO = get_normSCO(SCO_new_temp,size(SCO_new_temp,3));
    [Blocks_top,Rots_top] = do_greedy_assembly_replicate_new(Blocks,Rots,normSCO,nr*nc);
    Blocks_top_list{3} = Blocks_top;
    Rots_top_list{3} = Rots_top;
    clear normSCO Blocks_top Rots_top    
    
    %% do top & bottom and left & right
    
    SCO_new_temp = SCO_new;
    block = boundary.block;
    block_top = block(1,:);
    block_bottom = block(end,:);
    block_top = block_top(block_top>0);
    block_bottom = block_bottom(block_bottom>0);
    info_p1 = [block_top(:);block_bottom(:)];
    info_p4 = [ones(length(block_top(:)),1);3*ones(length(block_bottom(:)),1)];
    info_temp = [info_p1 ones(size(info_p1)) zeros(size(info_p1)) info_p4];
    info_temp_all = get_all_info(info_temp,nr*nc);
    for i = 1:size(info_temp_all,1)
        SCO_new_temp(info_temp_all(i,1),:,info_temp_all(i,4)) = inf;
        SCO_new_temp(:,info_temp_all(i,1),mirror(info_temp_all(i,4))) = inf;
    end
    
    block = boundary.block;
    block_left = block(:,1);
    block_right = block(:,end);
    block_left = block_left(block_left>0);
    block_right = block_right(block_right>0);
    info_p1 = [block_left(:);block_right(:)];
    info_p4 = [ones(length(block_left(:)),1)*4;2*ones(length(block_right(:)),1)];
    info_temp = [info_p1 ones(size(info_p1)) zeros(size(info_p1)) info_p4];
    info_temp_all = get_all_info(info_temp,nr*nc);
    for i = 1:size(info_temp_all,1)
        SCO_new_temp(info_temp_all(i,1),:,info_temp_all(i,4)) = inf;
        SCO_new_temp(:,info_temp_all(i,1),mirror(info_temp_all(i,4))) = inf;
    end
    
    normSCO = get_normSCO(SCO_new_temp,size(SCO_new_temp,3));
    [Blocks_top,Rots_top] = do_greedy_assembly_replicate_new(Blocks,Rots,normSCO,nr*nc);
    Blocks_top_list{4} = Blocks_top;
    Rots_top_list{4} = Rots_top;
    clear normSCO Blocks_top Rots_top

end
