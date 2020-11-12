%% get the score of the arbitary shape recovery result
%% randscram: the rotation of all the pieces

function [score,val] = eval_score(BlocksInfo,ppp,randscram,nr,nc)

if(isstruct(BlocksInfo))
    %% take the biggest component
    block_size = cellfun(@numel,BlocksInfo.Blocks);
    [val,ind] = max(block_size);
    val = val/(nr*nc);
    real_goal = BlocksInfo.Blocks{ind,1};
else
    real_goal = BlocksInfo;        
end
    
n = length(ppp);
gt = reshape(1:n,nr,nc);

msk = real_goal > 0;
sol = ppp(max(real_goal,1));
if(size(sol,1) ~= size(real_goal,1) || size(sol,2) ~= size(real_goal,2))
   sol = sol'; 
end
sol(~msk) = 0;
n_sol = sum(sum(msk));

%% get the biggest component
sol_comp = sol;
[L, num] = bwlabel(msk,4);
lab_count = zeros(num,1);
for i = 1:num
    lab_count(i) = sum(sum(L==i));
end
[~,ind] = max(lab_count);
sol_comp(L ~= ind) = 0;

%%
[nr_sol,nc_sol] = size(real_goal);
gt_pad = ones(nr+2*nr_sol,nc+2*nc_sol)*0.5;
gt_pad(nr_sol+1:nr_sol+nr,nc_sol+1:nc_sol+nc) = gt;

correct_num = 0;
comp_num = 0;

for i = 1:nr+nr_sol
    for j = 1:nc+nc_sol
        temp = gt_pad(i:i+nr_sol-1,j:j+nc_sol-1);
        diff = temp - sol;
        cur_num = sum(sum(diff==0));
        if(cur_num > correct_num)
            correct_num = cur_num;
        end        
        diff_comp = temp - sol_comp;
        cur_comp_num = sum(sum(diff_comp==0));
        if(cur_comp_num > comp_num)
            comp_num = cur_comp_num;
        end
    end
end

correct_perc = correct_num/n;
correct_perc_sol = correct_num/n_sol;

comp_perc = comp_num/n;
comp_perc_sol = comp_num/n_sol;

%% check pairwise scores
info = [];
for i = 1:4
    
    switch i
        case 1  % layer 1, top
            id1 = real_goal(2:end,:);
            id2 = real_goal(1:end-1,:);
        case 2  % layer 2, right
            id1 = real_goal(:,1:end-1);
            id2 = real_goal(:,2:end);
        case 3  % layer 3, bottom
            id1 = real_goal(1:end-1,:);
            id2 = real_goal(2:end,:);
        case 4  % layer 4, left
            id1 = real_goal(:,2:end);
            id2 = real_goal(:,1:end-1);
    end
    
    id1 = id1(:);
    id2 = id2(:);
    mask = id1 > 0 & id2 > 0;
    id1 = id1(mask);
    id2 = id2(mask);
    temp = [id1 id2 ones(size(id1,1),1) ones(size(id1,1),1)*i];
    info = [info;temp];
    
end

good = check_match(info,ppp,randscram,nr,1);
pair_gt = sum(good)/(4*nr*nc-2*nr-2*nc);
pair_sol = sum(good)/length(good);

score = [correct_perc pair_gt comp_perc;
        correct_perc_sol pair_sol comp_perc_sol];

end