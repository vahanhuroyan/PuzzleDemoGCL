%% Jigsaw Puzzle Demo
for num = 1
    
    Parameters.num = num; % which dataset to run
    
    %% Parameter Setting
    PuzzleParametersSet;

    Parameters.doType2 = 1; % run Type2 puzzle

    %% Run Jigsaw Puzzle
    PP = Parameters.PP; nr = Parameters.nr; nc = Parameters.nc;
    kk = Parameters.kk; iter = Parameters.iter; thresh = Parameters.thresh;
    doType2 = Parameters.doType2; name_format = Parameters.name_format; name_format = regexprep(name_format,'[\s]+$','');
    method = Parameters.method; im_total = Parameters.im_total; noise = Parameters.noise;
    dataset_path = Parameters.dataset_path; rigid_conncomp = Parameters.rigid_conncomp;
    ScramblePositions = Parameters.ScramblePositions; ScrambleRotations = Parameters.ScrambleRotations;
    speed_up = Parameters.speed_up;

    
    %% match check
    buddy_check = Parameters.match.buddy_check;
    loop_check = Parameters.match.loop_check;
    loop_check2 = Parameters.match.loop_check2;
    
    ranking_method = 'inliers_minus_outliers/';
    rigid_conncomp_list = [1 0];
%     rigid_conncomp_list = 0;
    
    scores_all = zeros(im_total,4);   %% the scores of all images, noise free case
    
    buddy_check_list = [0 1 1 1];
    loop_check_list = [0 0 1 1];
    loop_check2_list = [0 0 0 1];
       
    %% compute the scores of the best combination
    %% only used for Type2 puzzle
    scores_all = zeros(im_total,4);
    for im_num = 1:im_total
        rank_score = 0;
        for rigid_conncomp = rigid_conncomp_list        
            for test = 1:4
                buddy_check = buddy_check_list(test);
                loop_check = loop_check_list(test);
                loop_check2 = loop_check2_list(test);
                save_path = [dataset_path sprintf('kk_%d_iter_%g_thresh_%g_method_%d_match_%d_%d_%d/', ...
                    kk,iter,thresh,method,buddy_check,loop_check,loop_check2)];
                save_path = [save_path sprintf('im_%d/',im_num)];
                if(~rigid_conncomp)
                    save_path = fullfile(save_path,'no_rigid/');
                else
                    save_path = fullfile(save_path,'rigid/');
                end
                if(doType2)
                    save_path = [save_path 'type2/'];
                end                
               
                try
                    save_path = fullfile(save_path,ranking_method);
                    load([save_path 'max_rank_score.mat']);
                    load([save_path 'scores.mat']);
                    if(max_rank_score > rank_score)
                        rank_score = max_rank_score;
                        scores_all(im_num,1:3) = scores;
                    end
                catch
                    continue;
                end
            end
        end
        im_num
        rank_score
        scores
        if(scores_all(im_num,1) == 1)
            scores_all(im_num,4) = 1;
        end
    end
    %% create log file
    dataset_score = [mean(scores_all(:,1:3),1) sum(scores_all(:,4))];
    curtime = clock;
    logname_OptimParams = 'jigsaw_log_new.txt';
    fid = fopen(logname_OptimParams ,'a');
    %             fprintf(fid,'\n**%g/%g/%g,%g:%02d : Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
    %                 curtime(1:5), Parameters.num,doType2,rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
    
    fprintf(fid,'\n**%g/%g/%g,%g:%02d : SpeedUp%d---Method_%d---Thresh_%g---Dataset_%d---Type_%d--BESTScores_[%g %g %g %g]', ...
        curtime(1:5), Parameters.speed_up,Parameters.method,Parameters.thresh,Parameters.num,doType2, ...
        dataset_score(1:4));
    
    fclose(fid);
    
end