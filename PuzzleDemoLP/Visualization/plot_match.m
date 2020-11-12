%% plot the pairwise match on the ground truth

function info_good = plot_match(info,ppp,randscram,nr,nc,ap,PP,varargin)

[step,test,buddy_check,loop_check,loop_check2,new_data,speed_up,ranking_method] = getPrmDflt(varargin,{'step',0,'test',1, ...
    'buddy_check',0,'loop_check',0,'loop_check2',0,'new_data',0,'speed_up',0, 'ranking_method','inliers_minus_outliers'}, 1);

n_bk = nr*nc;
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

num = n/(nr*nc);
nc = nc*num;

figure

for i = 1:nr
    for j = 1:nc
        ind = gt(i,j);
        gt_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:) = imrotate(ap{ind},-90*(randscram(ind)-1));
%         gt_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:) = ap{ind};
    end
end

if(max(gt_im(:)) > 255)
    imshow(uint16(gt_im),'border','tight');
else
    imshow(uint8(gt_im),'border','tight');
end

hold on

p1 = ppp(info(:,1));
p2 = ppp(info(:,2));

[r1,c1] = ind2sub([nr,nc],p1);
[r2,c2] = ind2sub([nr,nc],p2);

r1 = (r1-0.5)*PP;
c1 = (c1-0.5)*PP;
r2 = (r2-0.5)*PP;
c2 = (c2-0.5)*PP;

if(num==1)
    good = check_match(info,ppp,randscram,nr,1);
else
    good = check_match_replicate(info,ppp,randscram,nr,1,n_bk);
end
    
fprintf('good match percentage %g \n',sum(good)/length(good));
good = logical(good);

info_good = info(good,:);

r1_r = r1(good);
c1_r = c1(good);
r2_r = r2(good);
c2_r = c2(good);

r1_w = r1(~good);
c1_w = c1(~good);
r2_w = r2(~good);
c2_w = c2(~good);

if(step)
    for i = 1:step:length(c1_r)
        quiver(c1_r(i),r1_r(i),c2_r(i)-c1_r(i),r2_r(i)-r1_r(i), ... 
            'Autoscale','off','ShowArrowHead','off','color',[0.5 0.5 1],'LineWidth',3);        
        pause;
    end
    for i = 1:step:length(c1_w)
        quiver(c1_w(i),r1_w(i),c2_w(i)-c1_w(i),r2_w(i)-r1_w(i), ...
            'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',3);
        pause;
    end
else    
%     quiver(c1_r,r1_r,c2_r-c1_r,r2_r-r1_r,'Autoscale','off','ShowArrowHead','off','color',[0.5 0.5 1],'LineWidth',3);
    quiver(c1_r,r1_r,c2_r-c1_r,r2_r-r1_r,'Autoscale','off','ShowArrowHead','off','color',[0 0 1],'LineWidth',3);
    quiver(c1_w,r1_w,c2_w-c1_w,r2_w-r1_w,'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',3,'LineStyle','--');
end

end

function ind_rank = my_sort(ind,piece_num)    
    ind_remainder = mod(ind-1,piece_num);
    [~,ind_rank] = sort(ind_remainder);
end