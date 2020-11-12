%% get ground truth pieces for comparison
function GT = get_ground_truth_replicate(ppp,randscram,nr,nc,ap,PP)

n = length(ppp);
gt = 1:n;
gt(ppp) = 1:n;

if(n == nr*nc)
    gt = reshape(gt,nr,nc);
    gt_im = zeros(nr*PP,nc*PP,3);
else
    % 4 times more pieces
%     gt = zeros(2*nr,2*nc);

% %     temp = gt;
% %     gt(1:nr,1:nc) = reshape(temp(1:nr*nc),nr,nc);
% %     gt(1:nr,nc+1:2*nc) = reshape(temp(nr*nc+1:2*nr*nc),nr,nc);
% %     gt(1:nr,2*nc+1:3*nc) = reshape(temp(2*nr*nc+1:3*nr*nc),nr,nc);
% %     gt(1:nr,3*nc+1:4*nc) = reshape(temp(3*nr*nc+1:4*nr*nc),nr,nc);
% %     gt_im = zeros(nr*PP,4*nc*PP,3);    

    gt = zeros(nr,2*nc);
    
    ind1 = find(randscram == 1);
    temp = ppp(ind1);
    ind1_rank = my_sort(temp,nr*nc);
    gt(1:nr,1:nc) = reshape(ind1(ind1_rank),nr,nc);
    
    ind2 = find(randscram == 2);
    temp = ppp(ind2);
    ind2_rank = my_sort(temp,nr*nc);
    gt(1:nr,nc+1:2*nc) = reshape(ind2(ind2_rank),nr,nc);
    
    ind3 = find(randscram == 3);
    temp = ppp(ind3);
    ind3_rank = my_sort(temp,nr*nc);
    gt(1:nr,2*nc+1:3*nc) = reshape(ind3(ind3_rank),nr,nc);
    
    ind4 = find(randscram == 4);
    temp = ppp(ind4);
    ind4_rank = my_sort(temp,nr*nc);
    gt(1:nr,3*nc+1:4*nc) = reshape(ind4(ind4_rank),nr,nc);
    
    gt_im = zeros(nr*PP,4*nc*PP,3);
    
end

GT = cell(4,1);

GT{1} = gt(1:nr,1:nc);
GT{2} = gt(1:nr,nc+1:2*nc);
GT{3} = gt(1:nr,2*nc+1:3*nc);
GT{4} = gt(1:nr,3*nc+1:4*nc);

for i = 2:4   
   GT{i} = imrotate(GT{i},90*(i-1));    
end

num = n/(nr*nc);
nc = nc*num;

% % figure
% % 
% % for i = 1:nr
% %     for j = 1:nc
% %         ind = gt(i,j);
% %         gt_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:) = imrotate(ap{ind},-90*(randscram(ind)-1));
% % %         gt_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:) = ap{ind};
% %     end
% % end
% % 
% % if(max(gt_im(:)) > 255)
% %     imshow(uint16(gt_im),'border','tight');
% % else
% %     imshow(uint8(gt_im),'border','tight');
% % end

end

function ind_rank = my_sort(ind,piece_num)    
    ind_remainder = mod(ind-1,piece_num);
    [~,ind_rank] = sort(ind_remainder);
end