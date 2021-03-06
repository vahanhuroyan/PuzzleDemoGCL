%% Jigsaw Puzzle Demo for illustration

for num = 1
    
    Parameters.num = num; % which dataset to run
    
    %% Parameter Setting
    PuzzleParametersSetIllustrate;
    
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
    
    for im_num = 1:im_total
        
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
                        'new_data',0,'speed_up',speed_up);
                    scores = [scores;res.score];
                    if(res.score(1) == 1)
                        perfect_num = perfect_num + 1;
                    end
                end
                perfect_num = perfect_num/noise.sample;
                save([save_path_temp 'scores.mat'],'scores');
                save([save_path_temp 'perfect.mat'],'perfect_num');
                
            end
        else
            [res,max_rank_score] = PuzzleMain(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path, ...
                'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2, ...
                'new_data',0,'speed_up',speed_up);
            scores = res.score;
            if(res.score(1) == 1)
                perfect_num = 1;
            else
                perfect_num = 0;
            end
            save([save_path 'max_rank_score.mat'],'max_rank_score');
            save([save_path 'scores.mat'],'scores');
            save([save_path 'perfect.mat'],'perfect_num');
            
            scores_all(im_num,1:3) = scores;
            scores_all(im_num,4) = perfect_num;
            
        end
        
    end
    
%     %% create log file
%     dataset_score = [mean(scores_all(:,1:3),1) sum(scores_all(:,4))];
%     curtime = clock;
%     logname_OptimParams = 'jigsaw_log.txt';
%     fid = fopen(logname_OptimParams ,'a');
%     %             fprintf(fid,'\n**%g/%g/%g,%g:%02d : Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
%     %                 curtime(1:5), Parameters.num,doType2,rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
%     
%     fprintf(fid,'\n**%g/%g/%g,%g:%02d : SpeedUp%d---Method_%d---Thresh_%g---Dataset_%d---Type_%d---Rigid_%d---Matches_%d_%d_%d---Scores_[%g %g %g %g]', ...
%         curtime(1:5), Parameters.speed_up,Parameters.method,Parameters.thresh,Parameters.num,doType2, ...
%         rigid_conncomp,buddy_check,loop_check,loop_check2,dataset_score(1:4));
%     
%     fclose(fid);    
    
end