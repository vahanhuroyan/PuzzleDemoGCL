%% main puzzle program

function [res,max_rank_score] = PuzzleMainRead(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path,varargin)

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

%% connected component trimming and filling
show = 0; max_rank_score = 0;
if(do_replicate)  % take the largest componet and left pieces
%     [im,max_rank_score,sols,real_goal] = replicate_trim_and_fill_new_loop_all(SCO,BlocksInfo,label,nr,nc,ap, ...
%         ScrambleRotations,show,'boundary',boundary,'speed_up',speed_up);    
    [im,max_rank_score,sols,real_goal] = read_scores(SCO,save_path,ranking_method);
    
else
    [im,max_rank_score,real_goal] = trim_and_fill_v2(SCO,BlocksInfo,label,nr,nc,ap,ScrambleRotations,show);
end

%% compute the scores
score = create_score(real_goal,nr,nc,ppp);
res.score = score;

%% save input and results
placementKey = reshape(1:nr*nc, nr,nc);
imS  = renderPiecesFromGraphIDs(ap,placementKey,0);

save_path = fullfile(save_path,ranking_method);

[~,name,ext] = fileparts(imname);
imname = [name ext];
if(~exist(save_path,'dir'))
   mkdir(save_path);
end

if(sample > 0)
    imwrite(imS,fullfile(save_path,sprintf('input_sample_%d_%s',sample,imname)));
    if(~isempty(im))
        imwrite(im,[save_path 'atf_' sprintf('sample_%d_',sample) imname]);
    end
    if(do_replicate)
        save([save_path 'sols_' sprintf('sample_%d',sample) '.mat'],'sols');
    end
else
    if(~isempty(im))
        imwrite(im,[save_path 'atf_' imname]);
    end
    imwrite(imS,fullfile(save_path,sprintf('input_%s',imname)));
    if(do_replicate)
        save([save_path 'sols.mat'],'sols');
    end
end