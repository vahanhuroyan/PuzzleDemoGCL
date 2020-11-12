%% save the pairwisr distance matrix to speed up
function [ap,ppp,randscram,SCO,do_replicate,ScrambleRotations] = LoadPuzzle(imname,PP,nc,nr,ScramblePositions,ScrambleRotations,varargin)

[add_imnoise,std,sample,new_data] = getPrmDflt(varargin,{'add_imnoise',0,'std',0,'sample',0,'new_data',0}, 1);
filename = [];
if(add_imnoise == 0)   %% no noise
    if(ScramblePositions && ~ScrambleRotations)
        filename = regexprep(imname,'.(jpg|png)$','_pos.mat');
    elseif(ScramblePositions && ScrambleRotations)
        filename = regexprep(imname,'.(jpg|png)$','_posrot.mat');
    end
elseif(~sample)      %% adding noise but using old data
    [pathstr,name,~] = fileparts(imname);
    noise_path = fullfile(pathstr,sprintf('std_%d',std));
    if(~exist(noise_path,'dir'))
       mkdir(noise_path);
    end
    filename = fullfile(noise_path,sprintf('%s_pos.mat',name));    
else                 %% adding noise and create new data
    [pathstr,name,~] = fileparts(imname);
    noise_path = fullfile(pathstr,sprintf('std_%d/%s/',std,name));
    if(~exist(noise_path,'dir'))
       mkdir(noise_path);
    end
    filename = fullfile(noise_path,sprintf('sample_%d.mat',sample));
end

if(exist(filename,'file') && new_data)
    delete(filename);
end

if(exist(filename,'file'))
    load(filename);
    ScrambleRotations = 0;
    return
else
    [pieceMat,ap, pi, im2] = PuzzleFun(imname,PP,nc,nr,'add_imnoise',add_imnoise,'std',std,'sample',sample);
end

if(sample)
   imwrite(im2,[noise_path sprintf('sample_%d.png',sample)]);
end

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
    ap4 = cell(4*numel(ap),1);
    randscram = floor(rand(numel(ap),1)*4)+1;
    for jj = 1:1:numel(ap)
        ap2{jj} = imrotate(ap{jj},90*(randscram(jj)-1));
    end
    ap=ap2;
    pnum = numel(ap);
    ap4(1:pnum) = ap;
    ppp4 = ppp;
    randscram4 = randscram;
    for k = 1:3
        for j = 1:pnum
            ap4{j+k*pnum} = imrotate(ap{j},k*90);
        end
        ppp4 = [ppp4 ppp+k*pnum];
        randscram4 = [randscram4;randscram+k];
    end
    mask = randscram4 > 4;
    randscram4(mask) = randscram4(mask) - 4;
end

%% Compute PuzzlePiece Atribute
fprintf('Compute Attributes for Puzzle\n');
pieceAttributes = ComputePieceAttributes(ap);  % Need to write this
fprintf('Done with Compute Attributes for Puzzle\n');

if(~ScrambleRotations)
    SCO = ComparePiecePairA_ROT_rui(ap, 7,pieceAttributes,ScrambleRotations);    
    randscram = ones(nr*nc,1);    
    do_replicate = 0;
else
    ScrambleRotations = 0;
    pieceAttributes4 = ComputePieceAttributes(ap4);  % Need to write this
    SCO_all_test = ComparePiecePairA_ROT_rui(ap4, 7,pieceAttributes4,ScrambleRotations);
    SCO_all_test = SCO_modify(SCO_all_test);
    randscram = randscram4;
    SCO = SCO_all_test;
    ppp = ppp4;
    ap = ap4;
    do_replicate = 1;
end

% save(filename,'randscram','ppp','ap','do_replicate','SCO','-v7.3');