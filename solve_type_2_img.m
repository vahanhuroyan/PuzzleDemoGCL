%
% Written by Vahan Huroyan
%
% solve_type_2_img - This function takes as input an image
% cuts it into calculates the rotations
%   Detailed explanation goes here


function [res_all_sol, err_all, real_goal_all, res_all, rotsNum_first, rotsNum] = solve_type_2_img(img_path, patch_size, cols, rows, numb_alg_iter)

    
%% load the puzzle, from a given image path and puzzle sizes

%     load(str_path); <- use this if you have already loaded and saved the
%     puzzle under the name str_path


% imlist= 'Image_Datasets/SmallImage/1.png'; 
% patch_size = 28; % square patch size
% cols = 24; % number of columns in puzzle image
% rows = 18;  % number of rows in puzzle image


% the construction of the puzzle part is identical with the code of
% PuzzleDemoLP
% numbOfParts = cols * rows;
% placementKey = reshape(1:rows*cols, rows, cols);

ScramblePositions = 0; % 0 to keep pieces in original locations, 1 to scrable
ScrambleRotations = 1; % 0 to keep upright orientation, 1 to scramble

%make the puzzle pieces:
[pieceMat,ap, pi] = PuzzleFun(img_path, patch_size, cols, rows);

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
pieceAttributes = ComputePieceAttributes(ap);
fprintf('Done with Compute Attributes for Puzzle\n');
fprintf('Compute Pairwise Compatibility Scores for Puzzle, Method %d\n',7);

% find scores between puzzle pieces
SCO_cr = ComparePiecePairA_ROT(ap, 7,pieceAttributes,ScrambleRotations); 


%% Finding the rotations part of the algorithm starts here
    
    
    [rot_mat_old, pos_mat_old, weights] = pairwiseRotPosWeight_nn(SCO_cr);
    [rot_mat, pos_mat, WW] = pairwiseRotPosWeight_4(SCO_cr);
%
    nn4Mat_orig = WW > 0;
    nn4Mat_orig = (nn4Mat_orig + nn4Mat_orig')/2;
%     nn4Mat_orig(nn4Mat_orig == 0.5) = 0.01;
    nn4Mat_orig(nn4Mat_orig == 0.5) = 0.01 * 8;
%
    pos_mat(pos_mat == 0) = pos_mat_old(pos_mat == 0);
    posMat_1 = (nn4Mat_orig > 0) .* pos_mat;
    nn4Mat_test = initial_nb_construct( nn4Mat_orig, posMat_1, SCO_cr );

% if i and j are neighbors, we want to check the number of neighbors in
% common they have
    nn4Mat_new = use_jaccard_index( nn4Mat_test);
    nn4Mat = 0.8 * nn4Mat_new + 0.2 * nn4Mat_test;

% make graph connected
    nn4Mat  = make_graph_connected(nn4Mat, weights );

% add missing rotation angles
    rot_mat(~abs(rot_mat)) = rot_mat_old(~abs(rot_mat));
    rotPatches = ap;

% find 4-loops
    [nn4Mat, rot_mat, diag_nb] = finding_4_loops( nn4Mat, rot_mat );
    rot_mat_orig = rot_mat;
    
%Calculate rotations
    eig_num = 5;
    [ rotPatches, rotsNum, rotations, A_for_VDD ] = calculate_rotations( nn4Mat + diag_nb/2, rot_mat, rotPatches, eig_num);
    
    rotsNum_first = rotsNum;
% updating the MGC values based on rotations
    [SCO_test] = reorder_SCO(SCO_cr, rotsNum);
    SCO_final = SCO_test(:, :, 1:4);

%Setting the parameters for the Yu et al algorithm 
    Parameters.nc = cols; Parameters.nr = rows;
    Parameters.kk = 1; Parameters.iter = 5;
    Parameters.thresh = 0.8; % matching threshold
    Parameters.method = 2; % 1:use ratio as weighting, 2:probabilistic weighting, 3:inverse distance weighting
    Parameters.PP = patch_size; 
    rot = ones(numel(ap),1);
    do_replicate = 0; rigid_conncomp = 0; buddy_check = 0; loop_check = 0; loop_check2 = 0; speed_up = 0;ranking_method = 0;

% using Yu et al algorithm to find the locations
    [res_all{1}, max_rank_score, real_goal, BlocksInfo] = PuzzleMain_test(Parameters, rotPatches, SCO_final, ppp, randscram, rot, 0, rigid_conncomp, do_replicate, buddy_check, loop_check, loop_check2, speed_up, ranking_method);
    err_all(1) = calculate_error(SCO_final, real_goal);
    res_all_sol{1} = res_all{1};
    rot_patches_temp = rotPatches;
    for i = 1:(cols*rows)
        rot_patches_temp{i} = rot90(rot_patches_temp{i});
    end
    SCO_test_temp = SCO_test;
    SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
    SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
    SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
    SCO_final_temp = SCO_test_temp(:, :, 1:4);

    [res_all{2}, max_rank_score, real_goal_1, BlocksInfo] = PuzzleMain_test(Parameters, rot_patches_temp, SCO_final_temp, ppp, randscram, rot, 0, rigid_conncomp, do_replicate, buddy_check, loop_check, loop_check2, speed_up, ranking_method);

    err_all(2) = calculate_error(SCO_final_temp, real_goal_1);
    if(err_all(1) > err_all(2))
        if(size(real_goal_1, 1) * size(real_goal_1, 2) >= size(real_goal, 1) * size(real_goal, 2))
            SCO_test = SCO_test_temp;
            real_goal = real_goal_1;
            rotPatches = rot_patches_temp;
            res_all_sol{1} = res_all{2};
        end
    end
    real_goal_all{1} = real_goal;
 
%   Uncomment this to see the result after the first step

%     figure;
%     large_Image = printLargeImage( rotPatches, cols, rows, real_goal(:));
%     imshow(uint16(large_Image));
%     imshow(large_Image);
    
    
%     for ttt = 1:5
    for ttt = 1:numb_alg_iter
% Find mismatches
        [real_goal_rem, connection_mat, median_dist_vec] = find_mismatches(real_goal, SCO_test, nn4Mat_test);

% Fill in the holes and update the connection function and the affinity
% function
        [rot_mat, nn4Mat] = fill_holes(real_goal_rem, rot_mat, rotsNum, rot_mat_orig, connection_mat, nn4Mat, SCO_test, median_dist_vec);
%update diagonnal neighbors
        [nn4Mat, rot_mat, diag_nb] = finding_4_loops( nn4Mat, rot_mat );    
        rot_mat_orig = rot_mat;
    
        [ rotPatches, rotsNum, rotations, A_for_VDD ] = calculate_rotations( nn4Mat + diag_nb/2, rot_mat, rotPatches, eig_num);

% updating the MGC values based on rotations
        [SCO_test] = reorder_SCO(SCO_test, rotsNum);
        SCO_final = SCO_test(:, :, 1:4);

        [res_all{2*ttt+1}, max_rank_score, real_goal, BlocksInfo] = PuzzleMain_test(Parameters, rotPatches, SCO_final, ppp, randscram, rot, 0, rigid_conncomp, do_replicate, buddy_check, loop_check, loop_check2, speed_up, ranking_method);
        err_all(2 * ttt + 1) = calculate_error(SCO_final, real_goal);
        res_all_sol{ttt+1} = res_all{2*ttt+1};
        rot_patches_temp = rotPatches;
        for i = 1:(cols*rows)
            rot_patches_temp{i} = rot90(rot_patches_temp{i});
        end
    
        SCO_test_temp = SCO_test;
        SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
        SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
        SCO_test_temp = SCO_test_temp(:, :, [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15]);
        SCO_final_temp = SCO_test_temp(:, :, 1:4);

        [res_all{2*ttt+2}, max_rank_score, real_goal_1, BlocksInfo] = PuzzleMain_test(Parameters, rot_patches_temp, SCO_final_temp, ppp, randscram, rot, 0, rigid_conncomp, do_replicate, buddy_check, loop_check, loop_check2, speed_up, ranking_method);

        err_all(2 * ttt + 2) = calculate_error(SCO_final_temp, real_goal_1);
        if(err_all(2 * ttt + 1) > err_all(2 * ttt + 2))
            if(size(real_goal_1, 1) * size(real_goal_1, 2) >= size(real_goal, 1) * size(real_goal, 2))
                SCO_test = SCO_test_temp;
                real_goal = real_goal_1;
                rotPatches = rot_patches_temp;
                res_all_sol{ttt} = res_all{2*ttt+2};
            end
        end
        
        real_goal_all{ttt+1} = real_goal;
        
        % uncomment this to see the result after each iteration
       
        figure;
        disp(size(real_goal));
        large_Image = printLargeImage( rotPatches, size(real_goal, 2), size(real_goal, 1), real_goal(:), img_path(end-2:end));
        imshow(large_Image);
        

    end
end

