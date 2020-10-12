function [rot_mat, pos_mat, weights] = pairwiseRotPosWeight_4(dist_mat)   
% function [weights, pos_mat] = pairwiseRotWeight_test_new(dist_mat)   

% pos_mat - 1->right, 2->up, 3->left, 4->bellow
	numbOfParts = size(dist_mat, 1);
    weights = zeros(numbOfParts);
    rot_mat = zeros(numbOfParts);
    pos_mat = zeros(numbOfParts);
%     pos_mat_1 = zeros(numbOfParts);
    a = zeros(4); b = zeros(4, 1);
    a(1, :) = 1:4:16;
    a(2, :) = 2:4:16;
    a(3, :) = 3:4:16;
    a(4, :) = 4:4:16;
    rots(1:4) = ones(1, 4);
    rots(5:8) = 1i*ones(1, 4);
    rots(9:12) = -1 * ones(1, 4);
    rots(13:16) = -1i*ones(1, 4);

    b(1) = 1; b(2) = 1i; b(3) = -1; b(4) = -1i;
    for i = 1:numbOfParts
        for k = 1:4
                x = squeeze(dist_mat(i, :, a(k, :)));
                
                y = sort(x(:)); 
%                 disp(size(x));
%                 disp(size((y)));
                [aa, bb] = min(x);
%               disp(size(aa));
                [val_1, ind_1] = min(aa);
                if(~weights(i, bb(ind_1)))
                    if(y(1) - y(2) ~= 0)  
                     	weights(i, bb(ind_1)) = val_1;
                        pos_mat(i, bb(ind_1)) = b(k);
                        sorted_weights = sort(unique(dist_mat(i, bb(ind_1), :)));
                        rot_mat(i, bb(ind_1)) = rots(a(k, ind_1));
                        if(sorted_weights(1) / sorted_weights(2) > 0.95)
                        	disp([int2str(i) '---close---'  int2str(bb(ind_1))]);
                            sec_best = find(dist_mat(i, bb(ind_1), :) == sorted_weights(2));
                            disp(sec_best);    
                            rot_mat(i, bb(ind_1)) = (1.1 * rot_mat(i, bb(ind_1)) + 0.9 * rots(sec_best(1)))/4;
                            
                        end
                    else 
                    	disp([int2str(i) 'aaaaa' int2str(bb(ind_1))]);
                    end
                elseif(val_1 < weights(i, bb(ind_1)))
                    disp([int2str(i) ' - ' int2str(bb(ind_1))])
%                     error('break');
                    if(y(1) - y(2) ~= 0)  
                        weights(i, bb(ind_1)) = val_1;
                        pos_mat(i, bb(ind_1)) = b(k);
                        rot_mat(i, bb(ind_1)) = rots(a(k, ind_1));
                    else
                        disp([int2str(i) 'bbbbb' int2str(bb(ind_1))]);
                    end
                end
        end
    end
    rot_mat = (rot_mat + rot_mat')/2;
end
