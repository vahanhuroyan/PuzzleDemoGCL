%% prepare and print data for ploting in R

%% prepare data
best_sols_scores = sols_scores_samples_all(16:16:end,:,:);
[para_num,score_num,~] = size(best_sols_scores);
sample_num = 5;
img_num = size(best_sols_scores,3)/sample_num;

best_sols_scores_sample_all = [];
best_sols_scores_sample = zeros(para_num,score_num,sample_num);

for i = 1:sample_num
    best_sols_scores_sample_imgs = best_sols_scores(:,:,i:sample_num:end);
    % compute the scores of sample i
    best_sols_scores_sample = sum(best_sols_scores_sample_imgs,3);
    best_sols_scores_sample(:,1:3) = best_sols_scores_sample(:,1:3)./img_num;    
    best_sols_scores_sample_all = [best_sols_scores_sample_all;best_sols_scores_sample];
end
    
%% print data
para_list = [300 500 700 1000 2000];
sample_list = ['sample1';'sample2';'sample3';'sample4';'sample5'];
score_list = ['Direct          ';'Neighbor        ';'LargestComponent';'Perfect         '];
save_folder = '../results';
file_name = 'speed_up_image_noise_sample.txt';
fid = fopen(fullfile(save_folder,file_name),'w');
    
for i = 1:para_num    
    for j = 1:sample_num        
        for k = 1:score_num         
            para = para_list(i);
            sample = sample_list(j,:);
            score = score_list(k,:);            
            value = best_sols_scores_sample_all((j-1)*para_num+i,k);
            fprintf(fid,'%d \t %.2f\t %s \t %s \n',para,value,score,sample);            
        end
    end
end

fclose(fid);

%% print data for all solutions
sols_scores_sample = reshape(sols_scores_samples_all,para_num*16,4,sample_num,img_num);
sols_scores_sample = sum(sols_scores_sample,4);
sols_scores_sample(:,1:3,:) = sols_scores_sample(:,1:3,:)./img_num;

para_list = [300 500 700 1000 2000];
sols_list = ['sol1 ';'sol2 ';'sol3 ';'sol4 ';'sol5 ';'sol6 ';'sol7 ';'sol8 '; ...
             'sol9 ';'sol10';'sol11';'sol12';'sol13';'sol14';'sol15';'solbt'];
sample_list = ['sample1';'sample2';'sample3';'sample4';'sample5'];
score_list = ['Direct          ';'Neighbor        ';'LargestComponent';'Perfect         '];
save_folder = '../results';
file_name = 'speed_up_image_noise_sample_sols.txt';
fid = fopen(fullfile(save_folder,file_name),'w');

sol_num = 16;
for j = 1:sample_num
    for k = 1:score_num
        for i = 1:para_num
            for sol = 1:sol_num
                para = para_list(i);
                solution = sols_list(sol,:);
                sample = sample_list(j,:);
                score = score_list(k,:);
                value = sols_scores_sample(sol_num*(i-1)+sol,k,j);
                fprintf(fid,'%d \t %s \t %.2f\t %s \t %s \n',para,solution,value,score,sample);
            end
        end
    end
end

fclose(fid);