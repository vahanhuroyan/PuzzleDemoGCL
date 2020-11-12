% function PuzzleBasedOnRanking_break(doType2,snr_para,sample,add_noise,add_normalization_noise,add_imnoise,map)
function PuzzleBasedOnRanking_break2(doType2,snr_para,sample,map,varargin)

[add_noise,add_normalization_noise,add_imnoise,rigid_conncomp] = getPrmDflt(varargin,{'add_noise',0,'add_normalization_noise',0, ...
    'add_imnoise',0,'rigid_conncomp',0}, 1);

%% Code of testing the idea of statistical ranking to solve jigsaw puzzle

%Demo Really Big Puzzle!
addpath ./PuzCode/

%% add gurobi
addpath('/cs/research/vision/humanis3/Rui/code/gurobi/gurobi563/linux64/matlab');
addpath('/cs/research/vision/humanis3/Rui/code/gurobi/gurobi563/linux64/examples/matlab');

global ap
global ppp

% imlist= 'DSC_1062.JPG';  % people watching waterfall, river
% imlist_new= 'DSC_1062_new.png';
% bit = 8;

% 432 540 805 2360 3300 5015 10375 22834
dataset.piece_num = [432 540 805 2360 3300 5015 10375 22834];
dataset.nr = [18 20 23 40 50 59 83 123];
dataset.nc = [24 27 35 59 66 85 125 185];
dataset.im_num = [20 20 20 3 3 20 20 20];

num = 1; % which dataset to run
PP = 28; %pixels in a piece

if(num == 1)
    dataset_path = sprintf('../Dataset/%d/png/',dataset.piece_num(num));
else
    dataset_path = sprintf('../Dataset/%d/',dataset.piece_num(num));
end

im_total = dataset.im_num(num);
nc = dataset.nc(num); % number of puzzle pieces across the puzzle
nr = dataset.nr(num);  % number of puzzle pieces up and down

method = 2;
kk = 1; iter = 5;
scores = [];
% % befscores = [];
ubounds = [];

do_replicate = 0;

% sample = 1;
% add_noise = 0;
% add_normalization_noise = 1;
% add_imnoise = 0;

% snr_para = 2000;
perfect_num = 0;

% map = [300 500 700 1000 2000];  %im_noise map
% map = 1:20;  % dissimilarity ratio map

map_num = length(map);
imnum = floor((snr_para-1)/map_num)+1;
snr_para = snr_para-map_num*(imnum-1);

snr_para = map(snr_para);

std = 0;
if(add_imnoise)
    std = snr_para;
end

% doType2 = 0;

if(add_noise && ~add_normalization_noise)
    save_path = [dataset_path 'RuiBreak/' sprintf('Rui_SCO_SNR_%g/',snr_para)];
elseif(~add_noise && add_normalization_noise)
    save_path = [dataset_path 'RuiBreak/' sprintf('Rui_normSCO_SNR_%g/',snr_para)];
elseif(add_imnoise)
    save_path = [dataset_path 'RuiBreak/' sprintf('Rui_imgnoise_%g/',std)];
else
    save_path = [dataset_path 'Rui/'];
end

if(~rigid_conncomp)
    save_path = fullfile(save_path,'no_rigid/');
else
    save_path = fullfile(save_path,'rigid2/');
end

save_path = [save_path sprintf('im_%d_kk_%d/',imnum,kk)];

if(doType2)
    save_path = [save_path 'type2/'];
end

for thresh = 0.7
    
    %     save_path = [res_path sprintf('kk_%d_thresh_%g/',kk,thresh)];
    %     save_path = [dataset_path sprintf('kk_%d_iter_%g/',kk,iter)];
    %     save_path = [dataset_path sprintf('kk_%d_iter_%g/',kk,iter)];
    %     save_path = [dataset_path sprintf('rot_kk_%d_iter_%g_thresh_%g_method_%d/',kk,iter,thresh,method)];
    
    if(exist(save_path,'dir') == 0)          % if the folder doesn't exsit
        mkdir(save_path);
    end
    
    %     for imnum = 1:im_total
    
    sample_scores = [];
    
    for test = 1:sample
        
        if(num == 1)
            imlist = sprintf('%d.png',imnum);
        else
            imlist = sprintf('%d.jpg',imnum);
        end
        
        try
            im = imread([dataset_path imlist]);
        catch
            imlist = sprintf('%02d.jpg',imnum);
        end
        
        %% get upperbpund for each image
        ubound = get_ubound([dataset_path imlist],PP,nr,nc);
        ubounds = [ubounds;ubound];
        
        imlist_new = imlist;
        
        placementKey = reshape(1:nr*nc, nr,nc);
        ScramblePositions =1;% 0 to keep pieces in original locations, 1 to scrable
        ScrambleRotations =doType2;% 0 to keep upright orientation, 1 to scramble
        
        %% load puzzle
        [ap,ppp,randscram,SCO,do_replicate,ScrambleRotations] = LoadPuzzle([dataset_path imlist],PP,nc,nr,ScramblePositions,ScrambleRotations, ...
            'add_imnoise',add_imnoise,'std',std,'newdata',test);
        %% added on Jan 28, 2015
        %         SCO(SCO==0) = 1;
        
        n = size(SCO,1);
        
        %% add noise to SCO
        if(add_noise)
            SCO_bk = SCO;
            for dimen = 1:size(SCO,3)
                SCO(:,:,dimen) = awgn(SCO(:,:,dimen),snr_para);
            end
            %% make sure normSCO is still symmetric
            for dimen = 1:size(SCO,3)
                tempU = triu(SCO(:,:,dimen));
                tempL = triu(SCO(:,:,mirror(dimen)))';
                SCO(:,:,dimen) = tempU + tempL;
            end
            SCO(SCO<=0) = SCO_bk(SCO<=0);
            clear SCO_bk
        end
        
        %% get potential matches and weights
        info = get_candidate_and_weight(SCO,kk,thresh,method, ...
            'add_normalization_noise',add_normalization_noise,'snr_para',snr_para);
        info_all = info;
        info = info_filter(info,do_replicate,nr*nc);
        
        %% get the best possible match and fix the position of one of the piece of this match
        fix_id = find_best_match(info,nr*nc,do_replicate);
        fix_value = [-100000;-100000];
        if(do_replicate)
            prob_id = fix_id+(-3:1:3)*nr*nc;
            mask = (prob_id > 0) & (prob_id < 4*nr*nc + 1);
            prob_id = prob_id(mask);
            fix_id = prob_id;
            fix_id = [fix_id;fix_id+n];
            add_value = [100000 100000 -100000;
                100000 -100000  100000];
            fix_value = [fix_value add_value];
            fix_id = fix_id(:);
            fix_value = fix_value(:);
        else
            fix_id = [fix_id;fix_id+nr*nc];
        end
        
        %% find out how many matches are correct
        if(~ScrambleRotations)
            rot = ones(numel(ap),1);
            rlabel = ones(numel(ap),1);
            info_keep = info;
            info_updated = info;
        else
            %% if the rotation is unknown, use MRF to solve rotation first
            [info_keep,rot,rlabel] = solve_rot_mrf(info,n);
            good = check_match(info_keep,ppp,randscram,nr,1);
            fprintf('pairwise match accurary before deleting %.3f\n',sum(good)/length(good));
            [info_updated,info_keep,del] = info_update(info_keep,rot,0);
        end
        
        %% formulate linear programs from candidate patches and weights
        [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated, ...
            'method','fix_point','fix_pos',fix_id,'fix_val',fix_value);
        lb = -inf(length(f),1);
        ub = inf(length(f),1);
        [x, ~, ~] = linprog(f, A, b, Aeq, beq, lb, ub);
        
        %% get correct connected component of the solution
        [label,info_keep] = get_connected_from_sol(x,info_keep,n,rot,'do_replicate',do_replicate,'piece_num',nr*nc,'loop',0);
        [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
            'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_no_loop',0);
        [fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value);
        size(BlocksInfo.Blocks,1)
        % %         %% accuracy of the arbitary shape result
        % %         befscore = eval_score(real_goal,ppp,randscram,nr,nc);
        % %         befscores = [befscores;befscore];
        method = 2;
        SCO_new = SCO;
        for it = 1:iter
            
            SCO_new = SCO_update(SCO_new,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label, ...
                'do_replicate',do_replicate,'piece_num',nr*nc);
            
            info_new = get_candidate_and_weight(SCO_new,kk,thresh,method, ...
                'add_normalization_noise',add_normalization_noise,'snr_para',snr_para);
            
            [info_new,info_del] = info_filter(info_new,do_replicate,nr*nc);
            
            %             info_del_track = [info_del_track;info_del];
            %             [~,info_del] = info_filter_loop(info_new,do_replicate,nr*nc);
            %             info_del_track = [info_del_track;info_del];
            %             SCO_new = SCO_update2(SCO_new,info_del,'do_replicate',do_replicate,'piece_num',nr*nc);
            
            if(ScrambleRotations)
                [info_new,rot,rlabel,x_updated] = solve_rot_mrf(info_new,n,'prev_rot',rot, ...
                    'prev_info',info_keep,'prev_label',label,'prev_x',x);
                [info_updated,info_new,del] = info_update(info_new,rot,0);
            else
                info_updated = info_new;
                x_updated = x;
            end
            info_new(:,3) = min(info_new(:,3),10);
            
            % if there is obvious conflicts between pieces, delete them
            % all, shoule be fine during the iteration
            %             [info_updated,info_new] = rm_info_conflict(info_updated,info_new);
            
            if(isempty(info_new))
                fprintf('There are no potential matches to deal with, break! \n');
                break;
            end
            
            %% backup previous solution x and labelling
            prev_x = x_updated;
            prev_label = label;
            prev_info = info_keep;
            
            %% formulate linear programs from candidate patches and weights
            if(rigid_conncomp)
                [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated,'method','connected_comp+fix_point','prev_label',label, ...
                    'prev_sol',x_updated(1:2*n),'fix_pos',fix_id,'fix_val',fix_value,'prev_info',prev_info);
            else
                [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated,'method','fix_point','prev_label',label, ...
                    'prev_sol',x_updated(1:2*n),'fix_pos',fix_id,'fix_val',fix_value,'prev_info',prev_info);
            end
            
            lb = -inf(length(f),1);
            ub = inf(length(f),1);
            [x, fval, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub);
            
            %% update labelling and check results
            [label,info_keep] = get_connected_from_sol(x,info_new,n,rot,'do_replicate',do_replicate, ...
                'update',1,'piece_num',nr*nc,'prev_info',prev_info,'loop',0);
            [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
                'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0, ...
                'break_no_loop',0,'keep_prev',1,'prev_info',prev_info);
            [fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value);
            size(BlocksInfo.Blocks,1)
            
            if(isequal(prev_label,label))
                fprintf('nothing really happened, break! \n');
                break;
            end
            
        end
        
        %% cut the component into to if necessary
        BlocksInfo_bk = BlocksInfo;
        BlocksInfo = BlocksInfo_cut(BlocksInfo,nr*nc);
        
        %% generate boundary
        %         boundary = find_boundary(BlocksInfo,info_all,info_keep,info_del_track,nr,nc);
        info_del_track = [];
        boundary = find_boundary_new(BlocksInfo,info_all,info_keep,info_del_track,nr,nc);
        
        %% connected component trimming and filling
        if(do_replicate)  % take the largest componet and left pieces
            [im,real_goal,real_rot,sols] = replicate_trim_and_fill_new_loop_all(SCO,BlocksInfo,label,nr,nc,ap, ...
                ScrambleRotations,0,'boundary',boundary);
        else
            [im,real_goal,real_rot] = trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0);
        end
        
        imwrite(im,[save_path 'atf_' sprintf('sample_%d_',test) imlist]);
        
        if(do_replicate)
            save([save_path 'sols_' sprintf('sample_%d',test) '.mat'],'sols');
        end
        
        %% compute the scores        
        sample_score = create_score(real_goal,nr,nc,ppp);
        sample_scores = [sample_scores;sample_score];
        
        if(sample_score(1) == 1)
            perfect_num = perfect_num + 1;
        end
        
        %% Input
        imS  = renderPiecesFromGraphIDs(ap,placementKey,0);
        %         figure(2);
        %         imagesc(imS);axis image;axis off
        %         title('original puzzle');
        %             imwrite(imS,fullfile(save_path,sprintf('input_%s',imlist)));
        imwrite(imS,[save_path 'atf_' sprintf('input_%d_%s',test,imlist)]);
        
    end
    
    % %         befscore = mean(sample_befscores);
    % %         befscores = [befscores;befscore];
    
    %         score = create_score(real_goal,nr,nc,ppp);
    score = mean(sample_scores,1);
    scores = [scores;score];
    
    %         save([save_path 'befscores.mat'],'befscores');
    
    %     end
    
    perfect_num = perfect_num/sample;
    %     aver = mean(scores);
    %     scores = [scores;aver];
    save([save_path 'scores.mat'],'scores');
    save([save_path 'perfect.mat'],'perfect_num');
    
    %     fid = fopen(break_txt, 'a+');
    %     fprintf(fid, '\n SNR: %d, %f, %f, %f\n', snr_para, aver(1), aver(2), aver(3));
    %     fclose(fid);
    
end