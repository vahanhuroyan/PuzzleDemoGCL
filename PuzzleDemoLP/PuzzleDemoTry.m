%% Jigsaw Puzzle Demo

%% Parameter Setting
PuzzleParametersSetRigidTry;

%% Run Jigsaw Puzzle
PP = Parameters.PP; nr = Parameters.nr; nc = Parameters.nc;
kk = Parameters.kk; iter = Parameters.iter; thresh = Parameters.thresh; 
doType2 = Parameters.doType2; name_format = Parameters.name_format; name_format = regexprep(name_format,'[\s]+$','');
method = Parameters.method; im_total = Parameters.im_total; noise = Parameters.noise; 
dataset_path = Parameters.dataset_path; rigid_conncomp = Parameters.rigid_conncomp;
ScramblePositions = Parameters.ScramblePositions; ScrambleRotations = Parameters.ScrambleRotations;

%% match check
buddy_check = Parameters.match.buddy_check;
loop_check = Parameters.match.loop_check;
loop_check2 = Parameters.match.loop_check2;

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
                        'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2,'new_data',0);
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
        res = PuzzleMain(Parameters,imname,PP,nc,nr,ScramblePositions,ScrambleRotations,rigid_conncomp,save_path, ... 
                        'buddy_check',buddy_check,'loop_check',loop_check,'loop_check2',loop_check2,'new_data',0);                    
        scores = res.score;
        if(res.score(1) == 1)
            perfect_num = 1;
        else
            perfect_num = 0;
        end
        save([save_path 'scores.mat'],'scores');
        save([save_path 'perfect.mat'],'perfect_num');        
    end
    
end