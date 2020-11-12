%% delete those matches having conflicts
%% if there are 2 or more matches corresponding to the same configuration, delete all those matches

function [info,info_new] = rm_info_conflict(info,info_new)

if(isempty(info))
    return;
end

num = length(unique(info(:,4)));
info_del = [];

for i = 1:num
    
    mask =  info(:,4) == i;
    info_i = info(mask,:);
    
    info_i1 = unique(info_i(:,1));
    info_i2 = unique(info_i(:,2));
    
    mask1 = false(sum(mask),1);
    mask2 = false(sum(mask),1);
    
    for k = 1:length(info_i1)        
        if(sum(info_i1(k) == info_i(:,1)) > 1)                    
            mask1 = mask1 | info_i1(k) == info_i(:,1);
        end
    end
    
    for k = 1:length(info_i2)        
        if(sum(info_i2(k) == info_i(:,2)) > 1)               
            mask2 = mask2 | info_i2(k) == info_i(:,2);
        end
    end
    
    ind = find(mask);    
    info_del = [info_del;info(ind(mask1|mask2),1:2)];
    
    info(ind(mask1|mask2),:) = [];
    info_new(ind(mask1|mask2),:) = [];
    
end

%% remove other way round

if(~isempty(info) && ~isempty(info_del))

    mask = ismember(info(:,1:2),info_del,'rows') | ismember(info(:,2:-1:1),info_del,'rows');
    info(mask,:) = [];
    info_new(mask,:) = [];

end

end