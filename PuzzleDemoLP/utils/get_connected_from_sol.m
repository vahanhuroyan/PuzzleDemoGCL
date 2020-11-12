%% get connected components based on info and x
function [label,info_keep,info_bk] = get_connected_from_sol(x,info,n,rot,varargin)

[update,prev_info,do_replicate,piece_num,buddy_check,loop_check,loop_check2] = getPrmDflt(varargin,{'update',0,'prev_info',[], ...
    'do_replicate',0,'piece_num',[],'buddy_check',0,'loop_check',0,'loop_check2',0}, 1);

x = x(1:2*n);

info_bk = info;

if(update)
    info_add = prev_info;
    info = [info;info_add];
    info = unique(info,'rows');
end

% find all the good matches based on the solution
if(~do_replicate)
    good = check_match_lp(info,x,rot,n);
else
    good = check_match_lp(info,x,rot,n);
end

info_keep = info(logical(good),:);
info_keep = double(info_keep);

if(do_replicate)
    num = n/4;
else
    num = n;
end

%% match checking
if(buddy_check)
    info_keep = info_filter(info_keep,do_replicate,num);
end
if(loop_check)
    info_keep = info_filter_loop(info_keep,do_replicate,piece_num);
end
if(loop_check2)
   info_keep = info_filter_loop2(info_keep,do_replicate,piece_num);
end

% create edge graph based on the info
graph = sparse(info_keep(:,1),info_keep(:,2),ones(size(info_keep,1),1),n,n);
graph = graph + graph';
[~,label] = graphconncomp(graph,'Directed',0,'Weak',1);
label = label';

%% check the labelling results
% set those labels which have only one piece as -1
label_list = setdiff(unique(label),-1);
for i = 1:length(label_list)
    msk = label == label_list(i);
    if(sum(msk) == 1)
        label(msk) = -1;
    end
end