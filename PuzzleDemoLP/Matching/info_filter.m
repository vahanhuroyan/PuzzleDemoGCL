%% prefilter info to make sure that if there is a match between p1 and p2, then p2 and p1 must have the mirror match
%% if this is the replicate case, then all the corresponding rotation versions must also be there
function [info,info_del] = info_filter(info,do_replicate,num)

mirror = [3 4 1 2 16 13 14 15 9 10 11 12 6 7 8 5]';

info_bk = info;

info_trunk = info(:,[1 2 4]);
info_mirror = [info(:,2) info(:,1) mirror(info(:,4))];

mask = ismember(info_mirror,info_trunk,'rows');
info = info(mask,:);

%% we could just delete those matches which are not consistent in all four images
map = [1 4 3 2;
       2 1 4 3;
       3 2 1 4;
       4 3 2 1];

new_info = [];   
   
if(do_replicate)
    for i = 1:4
        mask = info(:,4) == i;
        mask_k = true(sum(mask),1);
        for k = 1:3
            mk_info = info(mask,:);
            mk_info(:,4) = map(i,k+1);
            mk_info(:,1:2) = mk_info(:,1:2)+k*num;
            temp = mk_info(:,1:2);
            temp(temp>4*num) = temp(temp>4*num) - 4*num;
            mk_info(:,1:2) = temp;            
            mask_k = mask_k & ismember(mk_info(:,[1 2 4]),info(:,[1 2 4]),'rows');
        end
        ind = find(mask);
        new_info = [new_info;info(ind(mask_k),:)];
    end
    info = new_info;
end

%% find out which part has been deleted
mask_del = ~ismember(info_bk,info,'rows');
info_del = info_bk(mask_del,:);
