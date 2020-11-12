%% main puzzle program

function [res,max_rank_score] = PuzzleMain(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path,varargin)

[add_imnoise,std,sample,buddy_check,loop_check,loop_check2,new_data,speed_up,ranking_method] = getPrmDflt(varargin,{'add_imnoise',0,'std',0,'sample',0, ... 
                                                                    'buddy_check',0,'loop_check',0,'loop_check2',0,'new_data',0,'speed_up',0, ...
                                                                    'ranking_method','inliers_minus_outliers'}, 1);

global ap
global ppp
                                                                
kk = Parameters.kk;
iter = Parameters.iter;
thresh = Parameters.thresh;
method = Parameters.method;

%% get upperbound score without noise
ubound = get_ubound(imname,PP,nr,nc);
res.ubound = ubound;

%% load puzzle
[ap,ppp,randscram,SCO,do_replicate,ScrambleRotations] = LoadPuzzle(imname,PP,nc,nr,ScramblePositions,ScrambleRotations, ...
    'add_imnoise',add_imnoise,'std',std,'sample',sample,'new_data',new_data);
rot = ones(numel(ap),1);

%% get matches
info = get_candidate_and_weight(SCO,kk,thresh,method);
%% for visualization only
%% plot input matches
ttt = info(:,1)+(info(:,2)-1)*size(SCO,1)+(info(:,4)-1)*size(SCO,1)*size(SCO,2);
info_mask = SCO(ttt)==0; info_input = info; info_input(info_mask,:) = [];
% figure(1); plot_match(info_input,ppp,randscram,nr,nc,ap,PP,varargin);

if(buddy_check)
    info = info_filter(info,do_replicate,nr*nc);
end

%% get the pieces to fix
[fix_id,fix_value] = get_fix_id_value_init(info,nr,nc,do_replicate);

if(do_replicate)
    n = nr*nc*4;
else
    n = nr*nc;
end

%% formulate linear programs from candidate patches and weights
[f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info,'method','fix_point','fix_pos',fix_id,'fix_val',fix_value);
lb = -inf(length(f),1); ub = inf(length(f),1); 
x = linprog(f, A, b, Aeq, beq, lb, ub);

%% get connected component from LP solution
[label,info] = get_connected_from_sol(x,info,n,rot,'do_replicate',do_replicate,'piece_num',nr*nc, ... 
                                      'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);
% [label,BlocksInfo,info] = recover_connected_block(label,x,n,ap,PP, ...
%     'rot',rot,'info',info,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_no_loop',1, ...
%                                       'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);
[label,BlocksInfo,info] = recover_connected_block(label,x,n,ap,PP, ...
    'rot',rot,'info',info,'plot_res',0,'pause_t',0.5,'do_replicate',0,'break_no_loop',0, ...
                                      'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);
                                  
%% plot removed matches
[~,loc] = ismember(info,info_input,'rows');
loc(loc==0) = [];
info_del = info_input; info_del(loc,:) = [];
% figure(2); plot_match(info_del,ppp,randscram,nr,nc,ap,PP,varargin);

%%
ttt = info(:,1)+(info(:,2)-1)*size(SCO,1)+(info(:,4)-1)*size(SCO,1)*size(SCO,2);
info_mask = SCO(ttt)==0; info_1LP = info; info_1LP(info_mask,:) = [];
% figure(3); plot_match(info_1LP,ppp,randscram,nr,nc,ap,PP,varargin);

%% change the fixing piece to be center of the largest component
[fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value);

%% get scores after first LP
if(~do_replicate)
    [befscore,befval] = eval_score(BlocksInfo,ppp,randscram,nr,nc);
    res.befscore = befscore;
    res.befval = befval;
end
SCO_new = SCO;

for i = 1:iter
    
    %% update distance matrix
    SCO_new = SCO_update(SCO_new,BlocksInfo,'rm_boundary',1,'method','conneced_comp','label',label, ...
        'do_replicate',do_replicate,'piece_num',nr*nc);
    
    %% propose new matches    
    info_new = get_candidate_and_weight(SCO_new,kk,thresh,method);    
    if(buddy_check)
        info_new = info_filter(info_new,do_replicate,nr*nc);
    end
    
    %% figure 4, new matches
    ttt = info_new(:,1)+(info_new(:,2)-1)*size(SCO,1)+(info_new(:,4)-1)*size(SCO,1)*size(SCO,2);
    info_new_mask = SCO(ttt)==0; info_new_plot = info_new; info_new_plot(info_new_mask,:) = [];
    %% also remove those new matches which are included in rejected set
    del_test = [info_del(:,[1 2]); info_del(:,[2 1])];
    [newisdel,locb] = ismember(info_new_plot(:,[1 2]),del_test(:,[1 2]),'rows');
    info_new_plot(newisdel,:) = [];
%     figure(4); plot_match(info_new_plot,ppp,randscram,nr,nc,ap,PP,varargin);
    
    %% remove matches
    [~,info_break_new] = BlocksInfo_cut(BlocksInfo,nr*nc);  %% get pairs to be removed
    if(~isempty(info_break_new))
        fix_id_x = get_all_ind(info_break_new(1),nr*nc);
        fix_id = [fix_id_x;fix_id_x+n]; fix_id = fix_id(:);
        [info_mask,~] = ismember(info(:,1:2),info_break_new,'rows');
        info(info_mask,:) = [];
    end    
    if(~isempty(info_new) && ~isempty(info_break_new))
        [info_new_mask,~] = ismember(info_new(:,1:2),info_break_new,'rows');
        info_new(info_new_mask,:) = [];        
    end
    
    if(isempty(info_new))
        fprintf('There are no potential matches to deal with, break! \n');
        break;
    end
    
    %% backup previous labelling and matches
    prev_label = label;
    prev_info = info;
    
    %% formulate linear programs from candidate matches and weights
    if(rigid_conncomp)
        [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_new,'method','connected_comp+fix_point','prev_label',label, ...
            'prev_sol',x(1:2*n),'fix_pos',fix_id,'fix_val',fix_value,'prev_info',prev_info);
    else
%         info_new(:,3) = info_new(:,3)*power(5,i);
        [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info_new,'method','fix_point','prev_label',label, ...
            'prev_sol',x(1:2*n),'fix_pos',fix_id,'fix_val',fix_value,'prev_info',prev_info);
    end    
    lb = -inf(length(f),1); ub = inf(length(f),1);
    x = linprog(f, A, b, Aeq, beq, lb, ub);
    
%     %% update labelling and check results
%     disp('-----------');
%     disp([size(x) n])
%     [label,info] = get_connected_from_sol(x,info_new,n,rot,'do_replicate',do_replicate, ...
%         'update',1,'piece_num',nr*nc,'prev_info',prev_info, ... 
%         'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);
%     
% %     [label,BlocksInfo,info] = recover_connected_block(label,x,n,ap,PP, ...
% %         'rot',rot,'info',info,'plot_res',0,'pause_t',0.5,'do_replicate',0, ...
% %         'break_no_loop',1,'keep_prev',1,'prev_info',prev_info, ...
% %         'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);
%     [label,BlocksInfo,info] = recover_connected_block(label,x,n,ap,PP, ...
%         'rot',rot,'info',info,'plot_res',0,'pause_t',0.5,'do_replicate',0, ...
%         'break_no_loop',0,'keep_prev',1,'prev_info',prev_info, ...
%         'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2);   
%     
%     %% plot the matches after second LP
%     ttt = info(:,1)+(info(:,2)-1)*size(SCO,1)+(info(:,4)-1)*size(SCO,1)*size(SCO,2);
%     info_mask = SCO(ttt)==0; info_2LP = info; info_2LP(info_mask,:) = [];
%     figure(5); plot_match(info_2LP,ppp,randscram,nr,nc,ap,PP,varargin);
%     
%     [fix_id,fix_value] = get_fix_id_value(BlocksInfo,do_replicate,nr,nc,n,fix_id,fix_value);
%     
%     if(isequal(prev_label,label))
%         fprintf('nothing really happened, break! \n');
%         break;
%     end
    
end

clear SCO_new

%% cut big component into 2 to if necessary
BlocksInfo = BlocksInfo_cut(BlocksInfo,nr*nc);
% BlocksInfo = BlocksInfo_cut_all(BlocksInfo,nr*nc);

%% get scores after LP iteration
if(~do_replicate)
   [aftscore,aftval] = eval_score(BlocksInfo,ppp,randscram,nr,nc);
   res.aftscore = aftscore;
   res.aftval = aftval;
end

%% generate boundary
boundary = find_boundary_new(BlocksInfo,nr,nc);

%% connected component trimming and filling
show = 0; max_rank_score = 0;
if(do_replicate)  % take the largest componet and left pieces
    [im,max_rank_score,sols,real_goal] = replicate_trim_and_fill_new_loop_all(SCO,BlocksInfo,label,nr,nc,ap, ...
        ScrambleRotations,show,'boundary',boundary,'speed_up',speed_up);    
else
    [im,max_rank_score,real_goal] = trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show);
end

%% compute the scores
score = create_score(real_goal,nr,nc,ppp);
res.score = score;

%% save input and results
% placementKey = reshape(1:nr*nc, nr,nc);
% imS  = renderPiecesFromGraphIDs(ap,placementKey,0);
% 
% save_path = fullfile(save_path,ranking_method);
% 
% [~,name,ext] = fileparts(imname);
% imname = [name ext];
% if(~exist(save_path,'dir'))
%    mkdir(save_path);
% end
% 
% if(sample > 0)
%     imwrite(imS,fullfile(save_path,sprintf('input_sample_%d_%s',sample,imname)));
%     if(~isempty(im))
%         imwrite(im,[save_path 'atf_' sprintf('sample_%d_',sample) imname]);
%     end
%     if(do_replicate)
%         save([save_path 'sols_' sprintf('sample_%d',sample) '.mat'],'sols');
%     end
% else
%     if(~isempty(im))
%         imwrite(im,[save_path 'atf_' imname]);
%     end
%     imwrite(imS,fullfile(save_path,sprintf('input_%s',imname)));
%     if(do_replicate)
%         save([save_path 'sols.mat'],'sols');
%     end
end