%% filter with loop constraints(keep the match as long as one loop verifies it)
%% num is used only when do_replicate is 1
%% delete those matches which:
%% 1: have a loop but this loop does not go back to itself(as long as there is one loop which does not go back to itself)
%% 2: doesn't have a loop

function [info,has_loop] = info_filter_loop2(info,do_replicate,num)

loop_matrix = [ 1 2 3 4;
                1 4 3 2;
                3 2 1 4;
                3 4 1 2;
                4 1 2 3;
                4 3 2 1;
                2 1 4 3;
                2 3 4 1];

ind_del = [];
has_loop = false(size(info,1),1);

for k = 1:8
    
    loop_k = loop_matrix(k,:);
    
    ind1 = find(info(:,4) == loop_k(1));
    if(isempty(ind1))
        continue;
    end    
    mask1 = true(length(ind1),1);
    bk = info(ind1,1);
    bk2 = info(ind1,2);
    
    ind2 = find(info(:,4) == loop_k(2));
    if(isempty(ind2))        
        continue;
    end
    [~,Locb] = ismember(bk2,info(ind2,1));
    bk3 = info(ind2(max(Locb,1)),2);
    mask1(Locb==0) = 0;
    
    ind3 = find(info(:,4) == loop_k(3));
    if(isempty(ind3))
        continue;
    end
    [~,Locb] = ismember(bk3,info(ind3,1));
    bk4 = info(ind3(max(Locb,1)),2);
    mask1(Locb==0) = 0;
    
    ind4 = find(info(:,4) == loop_k(4));
    if(isempty(ind4))
        continue;
    end
    [~,Locb] = ismember(bk4,info(ind4,1));
    bk_loop = info(ind4(max(Locb,1)),2);
    mask1(Locb==0) = 0;
    
    del = mask1 & (bk-bk_loop~=0);    % delete the info if the loop constraint is not satisfied
    ind_del = [ind_del;ind1(del)];
    
    has_loop(ind1(mask1)) = true;     % matches which have at least one loop
    
end

ind_keep = setdiff(1:size(info,1),ind_del);
ind_del = find(~has_loop);
ind_keep = setdiff(ind_keep,ind_del);

info = info(ind_keep,:);
info = info_filter(info,do_replicate,num);