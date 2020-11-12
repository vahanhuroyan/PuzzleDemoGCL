%% check piece to make sure they are correct
function check_piece(ap,ppp,imlist,nr,nc,PP)

num = numel(ppp);
im = imread(imlist);

figure(1)

for k = 1:num    
    
    im2 = im;
    
    patch1 = ap{k};    
    subplot(1,3,1);    
    imshow(patch1);
    title('ap');
    
    id1 = ppp(k);
    col1 = floor((id1-1)/nr)+1;
    row1 = id1-nr*(col1-1);
    patch1_gt = im(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,:);    
    subplot(1,3,2);
    imshow(patch1_gt);
    title('gt');
    
    subplot(1,3,3);
    
    im2(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,1) = 255;
    im2(PP*(row1-1)+1:PP*row1,PP*(col1-1)+1:PP*col1,2:3) = 0;
    im2(PP*(row1-1)+2:PP*row1-1,PP*(col1-1)+2:PP*col1-1,:) = im(PP*(row1-1)+2:PP*row1-1,PP*(col1-1)+2:PP*col1-1,:);    
    imshow(im2);
    title('input image');
    
    pause;
    
end

