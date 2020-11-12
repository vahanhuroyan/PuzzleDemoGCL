%% check the result of candidate matches
function check_random_match(info,ap,ppp,imlist,nr,nc,PP,fig_num)

n = size(info,1);
k = randi([1,n],1);

% show the result of kth match
k1 = info(k,1);
k2 = info(k,2);
weight = info(k,3);
config = info(k,4);

patch1 =  ap{k1};
patch2 =  ap{k2};

switch config
    case 1
        patch = [patch2;patch1];
    case 2
        patch = [patch1 patch2];
    case 3
        patch = [patch1;patch2];
    case 4
        patch = [patch2 patch1];
end

figure(fig_num)
subplot(1,3,1);
imshow(patch);
title(sprintf('weight is %d, %dth config',weight,config));

subplot(1,3,2);

im = imread(imlist);
im_bk = im;

id1 = ppp(k1);
id2 = ppp(k2);

col1 = floor((id1-1)/nr)+1;
row1 = id1-nr*(col1-1);
col2 = floor((id2-1)/nr)+1;
row2 = id2-nr*(col2-1);

patch1_gt = im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,:);
patch2_gt = im(PP*(row2-1)+1:PP*row2,PP*(col2-1)+1:PP*col2,:);

switch config
    case 1
        patch_gt = [patch2_gt;patch1_gt];
    case 2
        patch_gt = [patch1_gt patch2_gt];
    case 3
        patch_gt = [patch1_gt;patch2_gt];
    case 4
        patch_gt = [patch2_gt patch1_gt];
end

imshow(patch_gt); title('gt pieces');

subplot(1,3,3);

%% whole area
% im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,1) = 255;
% im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,2:3) = 0;
% im(PP*(row2-1)+1:PP*row2,PP*(col2-1)+1:PP*col2,2) = 255;
% im(PP*(row2-1)+1:PP*row2,PP*(col2-1)+1:PP*col2,[1 3]) = 0;

%% center
% im(PP*(row1-1)+PP/2-1:PP*(row1-1)+PP/2+1,PP*(col1-1)+PP/2-1:PP*(col1-1)+PP/2+1,1) = 255;
% im(PP*(row1-1)+PP/2-1:PP*(row1-1)+PP/2+1,PP*(col1-1)+PP/2-1:PP*(col1-1)+PP/2+1,2:3) = 0;
% im(PP*(row2-1)+PP/2-1:PP*(row2-1)+PP/2+1,PP*(col2-1)+PP/2-1:PP*(col2-1)+PP/2+1,2) = 255;
% im(PP*(row2-1)+PP/2-1:PP*(row2-1)+PP/2+1,PP*(col2-1)+PP/2-1:PP*(col2-1)+PP/2+1,[1 3]) = 0;

%% boundary
im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,1) = 255;
im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,2:3) = 0;
im(PP*(row2-1)+1:PP*row2,PP*(col2-1)+1:PP*col2,2) = 255;
im(PP*(row2-1)+1:PP*row2,PP*(col2-1)+1:PP*col2,[1 3]) = 0;
im(PP*(row1-1)+2:PP*row1-1,PP*(col1-1)+2:PP*col1-1,:) = im_bk(PP*(row1-1)+2:PP*row1-1,PP*(col1-1)+2:PP*col1-1,:);
im(PP*(row2-1)+2:PP*row2-1,PP*(col2-1)+2:PP*col2-1,:) = im_bk(PP*(row2-1)+2:PP*row2-1,PP*(col2-1)+2:PP*col2-1,:);

imshow(im);
title('input image');


end