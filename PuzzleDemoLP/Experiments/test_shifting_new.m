function test_shifting_new(mini,maxi)

%% add image noise
doType2 = 1;
sample = 5;
add_noise = 0;
add_normalization_noise = 0;
% add_imnoise = 1;
add_imnoise = 1;
map = [300 500 700 1000 2000];

for i = mini:maxi
    
    fprintf('number:%d\n',i);
    snr_para = i;
    
    PuzzleBasedOnRanking_break(doType2,snr_para,sample,map,'add_noise',add_noise,'add_normalization_noise', ...
        add_normalization_noise,'add_imnoise',add_imnoise,'rigid_conncomp',0);
    PuzzleBasedOnRanking_break2(doType2,snr_para,sample,map,'add_noise',add_noise,'add_normalization_noise', ...
                               add_normalization_noise,'add_imnoise',add_imnoise,'rigid_conncomp',0);
    
end