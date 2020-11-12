%% Jigsaw Puzzle Demo
for num = 2
    
    Parameters.num = num; % which dataset to run
    
    %% Parameter Setting
    PuzzleParametersSet;
    
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
    
    scores_all = zeros(im_total,4);   %% the scores of all images, noise free case
    
    buddy_check_list = [0 1 1];
    loop_check_list = [0 0 1];
    loop_check2_list = [0 0 0];
    
    %% ranking method
    ranking_method = 'inliers_minus_outliers/';
    rigid_conncomp_list = [1 0];
%     rigid_conncomp_list = 1;
    
    for rigid_conncomp = rigid_conncomp_list
        %     for rigid_conncomp = 1
        
        for test = 1:3
            %         for test = 1
            
            buddy_check = buddy_check_list(test);
            loop_check = loop_check_list(test);
            loop_check2 = loop_check2_list(test);
            
%             for im_num = 1:im_total
            for im_num = 3
 
%             for im_num = 1
                %             for im_num = 17
                
                %%
                fprintf('image number %d \n',im_num);
                
                %% set save path
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
                
                imname = fullfile(dataset_path,sprintf(name_format,im_num));
                
                if(noise.add_imnoise)   %% noise experiment
                    for noise_level = noise.noise_list
                        fprintf('noise level %d \n',noise_level);
                        save_path_temp = [save_path sprintf('imgnoise_%g/',noise_level)];
                        scores = []; perfect_num = 0;
                        for sample = 1:noise.sample
                            fprintf('sample %d \n',sample);
                            %% create new puzzle
                            res = PuzzleMain(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path_temp, ...
                                'add_imnoise',1,'std',noise_level,'sample',sample, ...
                                'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2, ...
                                'new_data',0,'speed_up',speed_up,'ranking_method',ranking_method);
                            scores = [scores;res.score];
                            if(res.score(1) == 1)
                                perfect_num = perfect_num + 1;
                            end
                        end
                        perfect_num = perfect_num/noise.sample;
                        
                        save_path_temp = fullfile(save_path_temp,ranking_method);
                        
%                         save([save_path_temp 'scores.mat'],'scores');
%                         save([save_path_temp 'perfect.mat'],'perfect_num');
                        
                    end
                else
                    [res,max_rank_score] = PuzzleMain(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path, ...
                        'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2, ...
                        'new_data',0,'speed_up',speed_up,'ranking_method',ranking_method);
                    scores = res.score;
                    if(res.score(1) == 1)
                        perfect_num = 1;
                    else
                        perfect_num = 0;
                    end
                    
                    save_path = fullfile(save_path,ranking_method);
%                     save([save_path 'max_rank_score.mat'],'max_rank_score');
%                     save([save_path 'scores.mat'],'scores');
%                     save([save_path 'perfect.mat'],'perfect_num');
                    
                    scores_all(im_num,1:3) = scores;
                    scores_all(im_num,4) = perfect_num;
                    
                end
                
            end
            
            %% create log file
            dataset_score = [mean(scores_all(:,1:3),1) sum(scores_all(:,4))];
            curtime = clock;
            logname_OptimParams = 'jigsaw_log.txt';
            fid = fopen(logname_OptimParams ,'a');
            %             fprintf(fid,'\n**%g/%g/%g,%g:%02d : Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
            %                 curtime(1:5), Parameters.num,doType2,rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
            
            fprintf(fid,'\n**%g/%g/%g,%g:%02d : SpeedUp%d---Method_%d---Thresh_%g---Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
                curtime(1:5), Parameters.speed_up,Parameters.method,Parameters.thresh,Parameters.num,doType2, ...
                rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
            
            fclose(fid);
            
        end
        
    end
    
    %% compute the scores of the best combination
    %% only used for Type2 puzzle
    scores_all = zeros(im_total,4);
    for im_num = 1:im_total
        rank_score = 0;
%         for rigid_conncomp = rigid_conncomp_list
        for rigid_conncomp = [1 0]
            for test = 1:3
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
                
                save_path = fullfile(save_path,ranking_method);
                
                try
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
    logname_OptimParams = 'jigsaw_log.txt';
    fid = fopen(logname_OptimParams ,'a');
    %             fprintf(fid,'\n**%g/%g/%g,%g:%02d : Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
    %                 curtime(1:5), Parameters.num,doType2,rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
    
    fprintf(fid,'\n**%g/%g/%g,%g:%02d : SpeedUp%d---Method_%d---Thresh_%g---Dataset_%d---Type_%d--BESTScores_[%g %g %g %g]', ...
        curtime(1:5), Parameters.speed_up,Parameters.method,Parameters.thresh,Parameters.num,doType2, ...
        dataset_score(1:4));
    
    fclose(fid);
    
end