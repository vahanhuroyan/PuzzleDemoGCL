function [new_patch_numb, rot_ang_numb, min_dist] = update_rotations_corners(coord_1, coord_2, real_goal_rem, SCO_test)
%UPDATE_ROTATIONS Summary of this function goes here
%   Detailed explanation goes here
%     i = 1, j = 1;
    numbOfParts = size(SCO_test, 1);
    dist_cur = zeros(4, numbOfParts);

    for cur_pt = 1:numbOfParts
        for rot_it = 1:4    
    
            if(coord_1 + 1 <= size(real_goal_rem, 1))
                c_b = real_goal_rem(coord_1 + 1, coord_2);
                if(c_b)
                    dist_cur(rot_it, cur_pt) = dist_cur(rot_it, cur_pt) + SCO_test(c_b, cur_pt, 1 + (rot_it - 1)*4);
                end
            end
            
            if(coord_2 - 1 > 0)
                c_l = real_goal_rem(coord_1, coord_2-1);
                if(c_l)
                    dist_cur(rot_it, cur_pt) = dist_cur(rot_it, cur_pt) + SCO_test(c_l, cur_pt, 2 + (rot_it - 1)*4);
                end
            end
    
            if(coord_1 - 1 > 0)
                c_t = real_goal_rem(coord_1 - 1, coord_2);
                if(c_t)
                    dist_cur(rot_it, cur_pt) = dist_cur(rot_it, cur_pt) + SCO_test(c_t, cur_pt, 3 + (rot_it - 1)*4);
                end
            end
    
            if(coord_2 + 1 <= size(real_goal_rem, 2))
                c_r = real_goal_rem(coord_1, coord_2+1);
                if(c_r)
                    dist_cur(rot_it, cur_pt) = dist_cur(rot_it, cur_pt) + SCO_test(c_r, cur_pt, 4 + (rot_it - 1)*4);
                end
            end
        end    
    end
    min_dist = min(min(dist_cur));
    [rot_ang_numb, new_patch_numb] = find( dist_cur == min_dist);
end

