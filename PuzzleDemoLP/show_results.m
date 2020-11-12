%% show results

show_num = 2;

dataset.root_path = '../Dataset';
dataset.root_path = '/cs/research/vision/humanis3/Rui/code/JigsawPuzzle/Dataset';
dataset.piece_num = [432 540 805 2360 3300 5015 10375 22834];
dataset.nr = [18 20 23 40 50 59 83 123];
dataset.nc = [24 27 35 59 66 85 125 185];
dataset.im_num = [20 20 20 3 3 20 20 20];
dataset.name_format = ['%d.png  ';'%d.jpg  ';'%d.jpg  ';'%d.jpg  '; ...
    '%d.jpg  ';'%02d.jpg';'%02d.jpg';'%02d.jpg'];

if(show_num == 1)
    dataset_path = fullfile(dataset.root_path,sprintf('/%d/png/',dataset.piece_num(show_num)));
else
    dataset_path = fullfile(dataset.root_path,sprintf('/%d/',dataset.piece_num(show_num)));
end

im_total = dataset.im_num(show_num);

% buddy_check = 1; % check info_filter
% loop_check =  1; % check info_filter_loop
% loop_check2 = 0; % check info_filter_loop2
% rigid_conncomp_list = 1;

buddy_check_list = [0 1 1];
loop_check_list = [0 0 1];
loop_check2_list = [0 0 0];

rigid_conncomp_list = [1 0];

% for rigid_conncomp = rigid_conncomp_list
for rigid_conncomp = 1
    
    for test = 1:3
        %     for test = 3
        
        buddy_check = buddy_check_list(test);
        loop_check = loop_check_list(test);
        loop_check2 = loop_check2_list(test);
        
        %                 for i = 1:im_total
        for i = 17
            
            save_path = [dataset_path sprintf('kk_%d_iter_%g_thresh_%g_method_%d_match_%d_%d_%d/', ...
                kk,iter,thresh,method,buddy_check,loop_check,loop_check2)];
            
            save_path = [save_path sprintf('im_%d/',i)];
            
            if(~rigid_conncomp)
                save_path = fullfile(save_path,'no_rigid/');
            else
                save_path = fullfile(save_path,'rigid/');
            end
            if(doType2)
                save_path = [save_path 'type2/'];
            end
            
            try
                im = imread(fullfile(save_path,fullfile(sprintf('atf_%d.png',i))));
            catch
                im = imread(fullfile(save_path,fullfile(sprintf('atf_%d.jpg',i))));
            end
            
            scores = load(fullfile(save_path,'scores.mat'))
            max_rank_score = load(fullfile(save_path,'max_rank_score.mat'))
            
            imshow(im);
            
            pause
            
        end
        
    end
    
end