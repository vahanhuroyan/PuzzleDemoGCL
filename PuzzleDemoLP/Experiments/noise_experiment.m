%% new experiments
%% add_normalization_noise

% Type1
% doType2 = 0;
% sample = 5;
% add_noise = 0;
% add_normalization_noise = 1;
% add_imnoise = 0;
% map = 1:20;
% 
% for i = 1:20*20
%     fprintf('experiment number:%d, snr_para:%d, img:%d \n',i,mod(i-1,20)+1,i-20*mod(i-1,20));
%     snr_para = i;
%     PuzzleBasedOnRanking_break(doType2,snr_para,sample,add_noise,add_normalization_noise,add_imnoise,map);
% end

% Type2
doType2 = 1;
sample = 1;
add_noise = 0;
add_normalization_noise = 1;
add_imnoise = 0;
map = 1:20;

% for i = 1:20*20
for i = 190:250
    fprintf('experiment number:%d, snr_para:%d, img:%d \n',i,mod(i-1,20)+1,i-20*mod(i-1,20));
    snr_para = i;
    PuzzleBasedOnRanking_break(doType2,snr_para,sample,add_noise,add_normalization_noise,add_imnoise,map);
end

%% add image noise
% doType2 = 1;
% sample = 1;
% add_noise = 0;
% add_normalization_noise = 0;
% add_imnoise = 1;
% map = [300 500 700 1000 2000];
% 
% for i = 1:5*20
% % for i = 28    
%     fprintf('number:%d\n',i);
%     snr_para = i;
%     PuzzleBasedOnRanking_break(doType2,snr_para,sample,add_noise,add_normalization_noise,add_imnoise,map);
% end