%
% Written by Vahan Huroyan
%
function [nn4Mat_var, var_vector] = penalize_small_var(ap, nn4Mat, pos_mat)
% for each patch try to find if the edge contains uniform color or not

% 1 -> right 2 -> left 3 -> top 4 -> bottom
% pos_mat - 1->right, 2->up, 3->left, 4->bellow
    
    numbOfParts = length(ap);
    var_vector = zeros(numbOfParts, 4);

    for i = 1:numbOfParts
        var_vector(i, 1) = var(double(ap{i}(:, end, 1)));
        var_vector(i, 2) = var(double(ap{i}(:, 1, 1))); 
        var_vector(i, 3) = var(double(ap{i}(1, :, 1))); 
        var_vector(i, 4) = var(double(ap{i}(end, :, 1))); 
    end
    
    thr(1) = median(var_vector(:, 1)) / 3;
    thr(2) = median(var_vector(:, 2)) / 3;
    thr(3) = median(var_vector(:, 3)) / 3;
    thr(4) = median(var_vector(:, 4)) / 3;
%     disp(thr);
    nn4Mat_var = zeros(size(nn4Mat));
    for i = 1:numbOfParts
        if(var_vector(i, 1) > thr(1))
            coords = find(nn4Mat(i, :));
            right_coord = coords(pos_mat(i, coords) == 1i);
%             disp([right_coord i]);
            if(nn4Mat(i, right_coord))
                nn4Mat_var(right_coord, i) = nn4Mat(i, right_coord);
                nn4Mat_var(i, right_coord) = nn4Mat(i, right_coord);
            end
        end
    
        if(var_vector(i, 2) > thr(2))
            coords = find(nn4Mat(i, :));
            left_coord = coords(pos_mat(i, coords) == -1i);
%             disp([left_coord i]);
            if(nn4Mat(i, left_coord))
                nn4Mat_var(left_coord, i) = nn4Mat(i, left_coord);
                nn4Mat_var(i, left_coord) = nn4Mat(i, left_coord);
            end
        end
    
        if(var_vector(i, 3) > thr(3))
            coords = find(nn4Mat(i, :));
            top_coord = coords(pos_mat(i, coords) == 1);
%             disp([top_coord i]);
            if(nn4Mat(i, top_coord))
                nn4Mat_var(top_coord, i) = nn4Mat(i, top_coord);
                nn4Mat_var(i, top_coord) = nn4Mat(i, top_coord);
            end
        end
    
        if(var_vector(i, 4) > thr(4))
            coords = find(nn4Mat(i, :));
            bottom_coord = coords(pos_mat(i, coords) == -1);
%             disp([bottom_coord i]);
            if(nn4Mat(i, bottom_coord))
                nn4Mat_var(bottom_coord, i) = nn4Mat(i, bottom_coord);
                nn4Mat_var(i, bottom_coord) = nn4Mat(i, bottom_coord);
            end
        end
    end
end

