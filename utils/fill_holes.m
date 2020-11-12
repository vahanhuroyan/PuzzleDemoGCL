%
% Written by Vahan Huroyan
%

function [rot_mat, nn4Mat] = fill_holes(real_goal_rem, rot_mat, rotsNum, rot_mat_orig, connection_mat, nn4Mat, SCO_test, median_dist_vec)
% this function finds the holes in the solution grid and finds the best
% possible patches to fill them up
    
    numbOfParts = size(rot_mat, 1);

    rem_patches = real_goal_rem(:);
    rem_patches = rem_patches(rem_patches ~= 0);
    rem_patches = sort(rem_patches(rem_patches~=0));
    
    T = inf * ones(numbOfParts, 1);
    T(rotsNum == 1) = 1i;
    T(rotsNum == 0) = 1;
    T(rotsNum == 2) = -1;
    T(rotsNum == 3) = -1i;

    rot_mat = repmat(transpose(T'), [1, numbOfParts]) .* rot_mat .* transpose(repmat(T, [1, numbOfParts]));
    rot_mat_orig = repmat(transpose(T'), [1, numbOfParts]) .* rot_mat_orig .* transpose(repmat(T, [1, numbOfParts]));
%
    con_temp = zeros(size(connection_mat));
    con_temp(rem_patches, rem_patches) = connection_mat(rem_patches, rem_patches);

    nn4Mat = 0.6 * nn4Mat + 0.4 * con_temp;

    rot_mat_old = rot_mat;
    nn4Mat_old = nn4Mat;

    for i = 1:size(real_goal_rem, 1)
        for j = 1:size(real_goal_rem, 2)
            nbs = [];
            if(~real_goal_rem(i, j))
                t = 0;
                if(i < size(real_goal_rem, 1))
                    if(real_goal_rem(i+1, j))
                        t = t + 1; nbs = [nbs real_goal_rem(i+1, j)];
                    end
                end
                if(j > 1)
                    if(real_goal_rem(i, j-1))
                        t = t + 1; nbs = [nbs real_goal_rem(i, j-1)];
                    end
                end
                if(i > 1)
                    if(real_goal_rem(i - 1, j)) 
                        t = t + 1; nbs = [nbs real_goal_rem(i - 1, j)];
                    end
                end
                if(j < size(real_goal_rem, 2))
                    if(real_goal_rem(i, j+1)) 
                        t = t + 1; nbs = [nbs real_goal_rem(i, j+1)];
                    end
                end
                if(t > 1)
                [new_patch_numb, rot_ang_numb, min_dist] = update_rotations_corners(i, j, real_goal_rem, SCO_test);                               
                    if(rot_ang_numb == 2)
                        rot_mat(nbs, new_patch_numb) = 1i;
                        rot_mat(new_patch_numb, nbs) = -1i;
                    end
                    if(rot_ang_numb == 3)
                        rot_mat(nbs, new_patch_numb) = -1;
                        rot_mat(new_patch_numb, nbs) = -1;
                    end
                    if(rot_ang_numb == 4)
                        rot_mat(nbs, new_patch_numb) = -1i;
                        rot_mat(new_patch_numb, nbs) = 1i;
                    end
                    nb_count = 0;
                    for nb_it = 1:length(nbs)
                        if(angle(rot_mat(new_patch_numb, nbs(nb_it))) == angle(rot_mat_orig(new_patch_numb, nbs(nb_it))))
                            nb_count = nb_count + 1;
                        end
                    end
                
%                 if(nb_count >= length(nbs)/2)
                    if((nb_count < 4 && length(nbs) > 1) || (nb_count == 4 && length(nbs) > 2))
                        if(min_dist/length(nbs) < median_dist_vec)
                            nn4Mat(nbs, new_patch_numb) = 0.6;
                            nn4Mat(new_patch_numb, nbs) = 0.6;
                        elseif(min_dist/length(nbs) < 2 * median_dist_vec)
                            nn4Mat(nbs, new_patch_numb) = 0.3;
                            nn4Mat(new_patch_numb, nbs) = 0.3;
                        else
%                       nn4Mat(nbs, new_patch_numb) = 0.05;
%                       nn4Mat(new_patch_numb, nbs) = 0.05;
                        end
                    
                    else
                        rot_mat(nbs, new_patch_numb) = rot_mat_old(nbs, new_patch_numb);
                        rot_mat(new_patch_numb, nbs) = rot_mat_old(new_patch_numb, nbs);
%                     pause;
                    end
                end
            end
        end
    end
%
rot_mat_0 = zeros(size(rot_mat));

rot_mat_0(rem_patches, rem_patches) = ones(length(rem_patches)) .* (nn4Mat(rem_patches, rem_patches) > 0); rot_mat_0 = rot_mat_0 > 0;
rot_mat(rot_mat_0) = rot_mat_0(rot_mat_0);
clear rot_mat_0;
end

