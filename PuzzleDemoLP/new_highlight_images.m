%% highlight the interesting regions

% results_path = '/cs/research/vision/home0/green/ruiyux01/data/Writing_up/JigsawPaper/figs/Examples';
results_path = '/home/cvfish/Work/papers/jigsawpaper/figs/Examples';

num = 15;

our_im = imread(fullfile(results_path,'Ours',sprintf('%d.png',num)));
son_im = imread(fullfile(results_path,'Son',sprintf('%d.png',num)));

method = 'Ours';
if(strcmp(method,'Son'))
    im = son_im;
else
    im = our_im;
end

close all

% subplot(1,2,1);
% imshow(our_im);
% subplot(1,2,2);
% imshow(son_im);

% upper_left = [1,1];
% lower_right = [9,7];

% upper_left = [1,1]+2;
upper_left = [3,5];
lower_right = [3,15]+4;

piece_size = 28;

line_width = 3;
crop_box = [upper_left-1; lower_right]*piece_size+1;
% plot the crop_box
imshow(uint8(im),'border','tight');
hold on
quiver(crop_box(1,2),crop_box(1,1),crop_box(2,2)-crop_box(1,2),0, ...
    'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',line_width);

quiver(crop_box(1,2),crop_box(1,1),0,crop_box(2,1)-crop_box(1,1), ...
    'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',line_width);

quiver(crop_box(2,2),crop_box(2,1),-crop_box(2,2)+crop_box(1,2),0, ...
    'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',line_width);

quiver(crop_box(2,2),crop_box(2,1),0,-crop_box(2,1)+crop_box(1,1), ...
    'Autoscale','off','ShowArrowHead','off','color',[1 0 0],'LineWidth',line_width);

hold off

im_crop = im(crop_box(1,1):crop_box(2,1)-1,crop_box(1,2):crop_box(2,2)-1,:);
figure
% imshow(im_crop);
imshow(uint8(im_crop),'border','tight');
imwrite(im_crop,sprintf('%s_%d_crop_small.png',method,num));

scale = 18/(lower_right(1) - upper_left(1) + 1);
im_crop = imresize(im_crop, scale);
figure
imshow(uint8(im_crop),'border','tight');
imwrite(im_crop,sprintf('%s_%d_crop.png',method,num));