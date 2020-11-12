
% snr_para = 20;

function PuzzleDemoMGC_break(snr_para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% This demo code creates and solves type 1 and type 2 jigsaw puzzles from
%%% an image.
%%%
%%%
%%% Copyright (C) 2012, Andrew Gallagher
%%% This code is distributed with a non-commercial research license.
%%% Please see the license file license.txt included in the source directory.
%%%
%%% Please cite this paper if you use this code:
%%%
%%%
%%% Jigsaw Pieces with Pieces of Unknown Orientation, Andrew Gallagher,
%%% CVPR 2012.
%%%
%%% Andrew Gallagher
%%% Aug. 15, 2012.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Break down your code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Demo Really Big Puzzle!
addpath ./PuzCode/

% 432 540 805 2360 3300 5015 10375 22834
dataset.piece_num = [432 540 805 2360 3300 5015 10375 22834];
dataset.nr = [18 20 23 40 50 59 83 123];
dataset.nc = [24 27 35 59 66 85 125 185];
dataset.im_num = [20 20 20 3 3 20 20 20];

num = 1; % which dataset to run
PP = 28; %pixels in a piece
dataset_path = sprintf('../Dataset/%d/png/',dataset.piece_num(num));
im_total = dataset.im_num(num);
nc = dataset.nc(num); % number of puzzle pieces across the puzzle
nr = dataset.nr(num);  % number of puzzle pieces up and down

add_noise = 0;
add_normalization_noise = 0;
add_imnoise = 1;

sample = 5;
% snr_para = 2000;
perfect_num = 0;
std = 0;

map = [300 500 700 1000 2000];  % image noise
% map = 1:20;  % ratio noise
map_num = length(map);
imnum = floor((snr_para-1)/map_num)+1;
snr_para = snr_para-map_num*(imnum-1);
snr_para = map(snr_para);

std = 0;
if(add_imnoise)
   std = snr_para;
end

doType2 = 1;

if(add_noise && ~add_normalization_noise)
    save_path = [dataset_path 'GallagherBreak/' sprintf('Gallagher_SCO_SNR_%g/',snr_para)];
elseif(~add_noise && add_normalization_noise)
    save_path = [dataset_path 'GallagherBreak/' sprintf('Gallagher_normSCO_SNR_%g/',snr_para)];
elseif(add_imnoise)
    save_path = [dataset_path 'GallagherBreak/' sprintf('Gallagher_imgnoise_%g/',std)];
else
    save_path = [dataset_path 'Gallagher/'];
end

save_path = [save_path sprintf('im_%d/',imnum)];

if(doType2)
    save_path = [save_path 'type2/'];
end

scores = [];

% break_txt = [dataset_path 'GallagherBreak/' 'Gallagher/' 'SNR_SCO_break.txt'];
% for snr_para = 60:-5:20
% save_path = [dataset_path 'GallagherBreak/' sprintf('Gallagher_SCO_SNR_%g/',snr_para)];
% save_path = [dataset_path 'GallagherBreak/' sprintf('Gallagher_normSCO_SNR_%g/',snr_para)];

inum = imnum;

sample_scores = [];
% %         sample_befscores = [];

for test = 1:sample
    
    fprintf('Processing %d/%d image \n',inum,im_total);
    
    % imlist= 'DSC_1062.JPG';  % people watching waterfall, river
    %     imlist= '1.png';
    im_name = sprintf('%d.png',inum);
    imlist = [dataset_path im_name];
    
    total_count = [nr*nc 2*nr*nc-nr-nc nr*nc];
    
    placementKey = reshape(1:nr*nc, nr,nc);
    ScramblePositions =1;% 0 to keep pieces in original locations, 1 to scrable
    ScrambleRotations =doType2;% 0 to keep upright orientation, 1 to scramble
    
    %make the puzzle pieces:
    %     [pieceMat,ap, pi] = PuzzleFun(imlist,PP, nc,nr);
    [pieceMat,ap, pi] = PuzzleFun(imlist,PP, nc,nr, ...
        'add_imnoise',add_imnoise,'std',std);
    
    % SCRAMBLE THE PIECES:
    if(ScramblePositions)
        ap2 = ap;
        ppp = randperm(numel(ap));
        for iii = 1:1:numel(ppp)
            ap2{iii} = ap{ppp(iii)};
        end
        ap=ap2;
    else
        ppp = 1:numel(ap);
    end
    if(ScrambleRotations)
        randscram = floor(rand(numel(ap),1)*4)+1;
        for jj = 1:1:numel(ap)
            ap2{jj} = imrotate(ap{jj},90*(randscram(jj)-1));
        end
        ap=ap2;
    end
    
    
    % compute PuzzlePiece Atribute
    fprintf('Compute Attributes for Puzzle\n');
    pieceAttributes = ComputePieceAttributes(ap);  % Need to write this
    fprintf('Done with Compute Attributes for Puzzle\n');
    
    fprintf('Compute Pairwise Compatibility Scores for Puzzle, Method %d\n',7);
    
    %     SCO = ComparePiecePairA_ROT(ap, 7,pieceAttributes,ScrambleRotations);
    SCO = ComparePiecePairA_ROT_rui(ap, 7,pieceAttributes,ScrambleRotations);
    %     for dimen = 1:size(SCO,3)
    %         SCO(:,:,dimen) = awgn(SCO(:,:,dimen),snr_para);
    %     end
    
    fprintf('Done with Score Computation for Puzzle Method %d\n',7);
    %     [GI, GR, im, Results] = DoAllAssemblyOfPuzzle(ap,SCO,nr,nc,1,ppp);
    [GI, GR, im, Results] = DoAllAssemblyOfPuzzle(ap,SCO,nr,nc,1,ppp, ...
        'add_noise',add_noise,'add_normalization_noise',add_normalization_noise,'snr_para',snr_para);
    
    if(exist(save_path,'dir') == 0)          % if the folder doesn't exsit
        mkdir(save_path);
    end
    
    imlist = im_name;
    
    %         figure;
    %         imagesc(im);axis image;axis off
    %         title('solved puzzle');
    %         % imwrite(im,'SolvedDemo.jpg','Quality',99);
%     imwrite(im,fullfile(save_path,imlist));
    imwrite(im,[save_path sprintf('sample_%d_',test) imlist]);
    
    imS  = renderPiecesFromGraphIDs(ap,placementKey,0);
    %         figure;
    %         imagesc(imS);axis image;axis off
    %         title('original puzzle');
    %         % imwrite(imS,'ScrambledDemo.jpg','Quality',99);
%     imwrite(imS,fullfile(save_path,sprintf('input_%s',imlist)));
    imwrite(imS,[save_path sprintf('input_%d_%s',test,imlist)]);
  
    % evaluate the results:
    G_safe = GI;
    G_undo = (G_safe==0);
    G_safe(G_safe==0) = 1;
    G_temptemp = ppp(G_safe);
    G_temptemp(G_undo) = 0;
    [Res] = EvalPuzzleAssembly(G_temptemp, nc, nr);
    
    accu = Res./total_count;
    sample_score = accu;
    sample_scores = [sample_scores;sample_score];
    
    if(sample_score(1) == 1)
        perfect_num = perfect_num + 1;
    end
    
end

score = mean(sample_scores);
scores = [scores;score];

% % count the number with the right rotation:
% G_temprot = GR(ppp);
% LUT = [1 4 3 2];
% sum(LUT(G_temprot)==randscram');
% cloc = Res(3); K = nr*nc;
% fprintf('\n\nAccuracy: %.0f pieces of %.0f are exactly in the correct position.\n', cloc,K );
% fprintf('Orientation: %d pieces have correct orientation.\n\n\n', sum(LUT(G_temprot)==randscram'));

perfect_num = perfect_num/sample;
% aver = mean(scores);
% scores = [scores;aver];
save([save_path 'scores.mat'],'scores');
save([save_path 'perfect.mat'],'perfect_num');

% fid = fopen(break_txt, 'a+');
% fprintf(fid, '\n SNR: %d, %f, %f, %f\n', snr_para, aver(1), aver(2), aver(3));
% fclose(fid);
% end