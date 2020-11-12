%
% Written by Vahan Huroyan
%

function [rot_mat, pos_mat, weights] = pairwiseRotPosWeight_4_test(dist_mat)   
% function [weights, pos_mat] = pairwiseRotWeight_test_new(dist_mat)   
% pos_mat - 1->right, 2->up, 3->left, 4->bellow
    
    numb_nb_dir = 1;

	numbOfParts = size(dist_mat, 1);
    weights = zeros(numbOfParts);
    rot_mat = zeros(numbOfParts);
    pos_mat = zeros(numbOfParts);
%     pos_mat_1 = zeros(numbOfParts);
    a = zeros(4); b = zeros(4, 1);
    a(1, :) = 1:4:16; a(2, :) = 2:4:16; a(3, :) = 3:4:16; a(4, :) = 4:4:16;
    rots(1:4) = ones(1, 4);
    rots(5:8) = 1i*ones(1, 4);
    rots(9:12) = -1 * ones(1, 4);
    rots(13:16) = -1i*ones(1, 4);

    b(1) = 1; b(2) = 1i; b(3) = -1; b(4) = -1i;
    for i = 1:numbOfParts
        for k = 1:4
%             pause;
                cur_weights = squeeze(dist_mat(i, :, a(k, :)));
                y = sort(cur_weights(:));
%               disp(size(y));
%               disp([sort_order(1:3)' y(1:3)']);
                thr = y(numb_nb_dir);
                [aa, bb] = find(cur_weights <= thr);
%                 disp([aa bb]);
%                 disp(size(bb));
%                 [val_1, ind_1] = min(aa);
                
        
                    if(y(1) - y(2) ~= 0)
                        for ll = 1:numb_nb_dir
                            weights(i, aa(ll)) = cur_weights(aa(ll), bb(ll));
                            pos_mat(i, aa(ll)) = b(k);
                            rot_mat(i, aa(ll)) = rots(a(k, bb(ll)));
%                             disp(ind_1)
%                             rot_mat(i, sort_order(ll)) = rots(a(k, ind_1));
                        end
                    else 
                    	disp([int2str(i) '--*--' int2str(bb(ind_1))]);
                    end
               
        end
    end
    rot_mat = (rot_mat + rot_mat')/2;
end
