%% Implementation of paper "Solving Jigsaw Puzzles with Linear Programming"

function PuzzleBasedOnRanking_break(doType2,snr_para,sample,map,varargin)

[add_noise,add_normalization_noise,add_imnoise,rigid_conncomp] = getPrmDflt(varargin,{'add_imnoise',0,'rigid_conncomp',0}, 1);

global ap
global ppp

%% set up parameters
PuzzleParametersSet;

%% create and solve puzzle
PuzzleDemo(Parameters);

for thresh = 0.7
    
    if(exist(save_path,'dir') == 0)          % if the folder doesn't exsit
        mkdir(save_path);
    end
    
    sample_scores = [];
    
    for test = 1:sample
        
        n = size(SCO,1);
        
        %% formulate linear programs from candidate patches and weights
        [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated, ...
            'method','fix_point','fix_pos',fix_id,'fix_val',fix_value);
        
        lb = -inf(length(f),1);
        ub = inf(length(f),1);
        [x, fval, exitflag] = linprog(f, A, b, Aeq, beq, lb, ub);
        
        %         %% only care about the value of the part of x which appears in info
        %         num = length(c);
        %         x(c) = x(1:num); x(c+num) = x((1:num)+num);
        %         x(num+1:n) = -1; x(n+num+1:2*n) = -1;
        
        info_ind = unique(info_updated(:,1:2));
        
        % %         %% recover the image
        %         [real_sol,real_goal,real_rot] = recover_im_from_x(x,n,nr,nc,ap,PP,'bit',bit, ...
        %             'rot',rot,'rlabel',rlabel,'info_ind',info_ind,'plot_res',1);
        
        %% get correct connected component of the solution
        [label,info_keep] = get_connected_from_sol(x,info_keep,n,rot,'do_replicate',do_replicate,'piece_num',nr*nc,'loop',2);
        %         [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP,'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5);
        %         [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
        %             'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0);
        %             [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
        %                 'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_conflict_inside_ccomp',1);
        %         [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
        %             'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_conflict_inside_ccomp',1);
        [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
            'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_no_loop',1);
        [fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value);
        size(BlocksInfo.Blocks,1)
        % %         %% accuracy of the arbitary shape result
        % %         befscore = eval_score(real_goal,ppp,randscram,nr,nc);
        % %         befscores = [befscores;befscore];
        method = 2;
        SCO_new = SCO;
        for it = 1:iter
            
            %             [SCO_new,fix_pos] = SCO_update(SCO,real_goal);
            %             SCO_new = SCO_update(SCO,real_goal,'rm_boundary',0,'method','conneced_comp','label',label);
            %             [SCO_new,fix_pos] = SCO_update(SCO,real_goal,'rm_boundary',1,'method','conneced_comp','label',label);
            %             SCO_new = SCO_update(SCO,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label);
            SCO_new = SCO_update(SCO_new,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label, ...
                'do_replicate',do_replicate,'piece_num',nr*nc);
            
            %             info_new = get_candidate_and_weight(SCO_new,kk,1,1);
            %             info_new = get_candidate_and_weight(SCO_new,kk,thresh,method);
%             info_new = get_candidate_and_weight(SCO,kk,thresh,method, ...
%                 'add_normalization_noise',add_normalization_noise,'snr_para',snr_para);
            info_new = get_candidate_and_weight(SCO_new,kk,thresh,method, ...
                'add_normalization_noise',add_normalization_noise,'snr_para',snr_para);
            
            [info_new,info_del] = info_filter(info_new,do_replicate,nr*nc);
            info_del_track = [info_del_track;info_del];
            [~,info_del] = info_filter_loop(info_new,do_replicate,nr*nc);
            info_del_track = [info_del_track;info_del];
            SCO_new = SCO_update2(SCO_new,info_del,'do_replicate',do_replicate,'piece_num',nr*nc);
            %             info_new = info_filter_loop(info_new,do_replicate,nr*nc);
            %             info_new = info_filter_loop2(info_new,do_replicate,nr*nc);
            
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
            [info_updated,info_new] = rm_info_conflict(info_updated,info_new);
            
            if(isempty(info_new))
                fprintf('There are no potential matches to deal with, break! \n');
                break;
            end
            
            %% backup previous solution x and labelling
            prev_x = x_updated;
            prev_label = label;
            prev_info = info_keep;
            
            %% formulate linear programs from candidate patches and weights
            %             [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated,'method','connected_comp','prev_label',label, ...
            %                 'prev_sol',x_updated(1:2*n));
            %             [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated, ...
            %                 'method','fix_point','fix_pos',fix_id,'fix_val',fix_value);
%             [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_updated,'method','connected_comp+fix_point','prev_label',label, ...
%                 'prev_sol',x_updated(1:2*n),'fix_pos',fix_id,'fix_val',fix_value,'prev_info',prev_info);

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
            %             [label,info_keep] = get_connected_from_sol(x,info_new,n,rot,'do_replicate',do_replicate,'update',1,'prev_info',prev_info);
            [label,info_keep] = get_connected_from_sol(x,info_new,n,rot,'do_replicate',do_replicate, ...
                'update',1,'piece_num',nr*nc,'prev_info',prev_info,'loop',2);
            %             [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP,'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5);
            %             [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
            %                 'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',1);
            %             [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
            %                 'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_conflict_inside_ccomp',1);
            %             [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
            %                 'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0, ...
            %                 'break_conflict_inside_ccomp',1,'keep_prev',1,'prev_info',prev_info);
            [label,BlocksInfo,info_keep] = recover_connected_block(label,x,n,ap,PP, ...
                'rot',rot,'info',info_keep,'plot_res',0,'pause_t',0.5,'do_replicate',0, ...
                'break_no_loop',1,'keep_prev',1,'prev_info',prev_info);
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
        boundary = find_boundary(BlocksInfo,info_all,info_keep,info_del_track,nr,nc);
%         boundary = find_boundary_new(BlocksInfo,info_all,info_keep,info_del_track,nr,nc);
        
        %% connected component trimming and filling
        if(do_replicate)  % take the largest componet and left pieces
            %             [im,real_goal,real_rot] = replicate_trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0);
            %               [im,real_goal,real_rot] = replicate_trim_and_fill_fast(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0);
            %             [im,real_goal,real_rot] = replicate_trim_and_fill_v3(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0);
%             [im,real_goal,real_rot] = replicate_trim_and_fill_new(SCO,BlocksInfo,label,nr,nc,ap, ...
%                 ScrambleRotations,0,'boundary',boundary);
%             [im,real_goal,real_rot] = replicate_trim_and_fill_new_loop(SCO,BlocksInfo,label,nr,nc,ap, ...
%                 ScrambleRotations,0,'boundary',boundary);
%             [im,real_goal,real_rot,sols] = replicate_trim_and_fill_new_loop_test(SCO,BlocksInfo,label,nr,nc,ap, ...
%                 ScrambleRotations,0,'boundary',boundary);
%             [im,real_goal,real_rot,sols] = replicate_trim_and_fill_new_loop_fast(SCO,BlocksInfo,label,nr,nc,ap, ...
%                 ScrambleRotations,0,'boundary',boundary);
            [im,real_goal,real_rot,sols] = replicate_trim_and_fill_new_loop_all(SCO,BlocksInfo,label,nr,nc,ap, ...
                ScrambleRotations,0,'boundary',boundary);
        else
            %         [im,real_goal,real_rot] = trim_and_fill(SCO,real_goal,real_rot,nr,nc,ap,ScrambleRotations,0);
            [im,real_goal,real_rot] = trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,0);
        end
        
        %             imwrite(im,[save_path 'atf_' imlist]);
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