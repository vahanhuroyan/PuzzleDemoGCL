%% get all the info because pieces are replicated 4 times
function [info,tag] = get_all_info(info,piece_num)

mat = [1 4 3 2;
       2 1 4 3;
       3 2 1 4;
       4 3 2 1];

info_all = [];   
tag = [];

for i = 1:4
   
    cycle = mat(i,:);
    mask = info(:,4) == cycle(1);
    info_i = info(mask,:);   
    info_new =info_i;
    tag = [tag;find(mask)];
    
    %% rotate 90 degrees
    temp = info_i;
    temp(:,1:2) = temp(:,1:2) + piece_num;
    mask1 = temp(:,1) > 4*piece_num;
    temp(mask1,1) = temp(mask1,1) - 4*piece_num;
    mask2 = temp(:,2) > 4*piece_num;
    temp(mask2,2) = temp(mask2,2) - 4*piece_num;    
    temp(:,4) = cycle(2);    
    info_new = [info_new;temp];
    tag = [tag;find(mask)];
    
    %% rotate 90*2 degrees
    temp = info_i;
    temp(:,1:2) = temp(:,1:2) + 2*piece_num;
    mask1 = temp(:,1) > 4*piece_num;
    temp(mask1,1) = temp(mask1,1) - 4*piece_num;
    mask2 = temp(:,2) > 4*piece_num;
    temp(mask2,2) = temp(mask2,2) - 4*piece_num;    
    temp(:,4) = cycle(3);
    info_new = [info_new;temp];
    tag = [tag;find(mask)];
    
    %% rotate 90*3 degrees
    temp = info_i;
    temp(:,1:2) = temp(:,1:2) + 3*piece_num;
    mask1 = temp(:,1) > 4*piece_num;
    temp(mask1,1) = temp(mask1,1) - 4*piece_num;
    mask2 = temp(:,2) > 4*piece_num;
    temp(mask2,2) = temp(mask2,2) - 4*piece_num;    
    temp(:,4) = cycle(4);
    info_new = [info_new;temp];
    tag = [tag;find(mask)];
        
    info_all = [info_all;info_new];
    
end

[info_all,ia] = unique(info_all,'rows');
info = info_all;
tag = tag(ia,:);

end