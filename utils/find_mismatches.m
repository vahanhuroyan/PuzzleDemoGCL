function [real_goal_rem, connection_mat, median_dist_vec] = find_mismatches(real_goal, SCO_test, nn4Mat_test)
% This function takes an assembled puzzle and finds mismatches in the
% solution grid
    numbOfParts = size(SCO_test, 1);
    dist_vec = -1 * ones(numbOfParts, 1);

    dist_vec_trb = -1 * ones(numbOfParts, 1);
    dist_vec_lrb = -1 * ones(numbOfParts, 1);
    dist_vec_tlb = -1 * ones(numbOfParts, 1);
    dist_vec_tlr = -1 * ones(numbOfParts, 1);

    dist_vec_lr = zeros(numbOfParts, 1);
    dist_vec_lt = zeros(numbOfParts, 1);
    dist_vec_lb = zeros(numbOfParts, 1);
    dist_vec_tr = zeros(numbOfParts, 1);
    dist_vec_tb = zeros(numbOfParts, 1);
    dist_vec_rb = zeros(numbOfParts, 1);

    for i = 1:size(real_goal, 1)
        for j = 1:size(real_goal, 2)
        % left
            t_l = 0;
            left = 0;
            if(j > 1 )
                t_l = t_l+1;
                left = squeeze(SCO_test(real_goal(i, j), real_goal(i, j - 1), 4));
            end
        % bottom
            bottom = 0;
            t_b = 0;
            if(i < size(real_goal, 1))
                t_b = t_b + 1;
                bottom = squeeze(SCO_test(real_goal(i, j), real_goal(i + 1, j), 3));
            end
        % right
            right = 0;
            t_r = 0;
            if(j < size(real_goal, 2))
                t_r = t_r + 1;
                right = squeeze(SCO_test(real_goal(i, j), real_goal(i, j + 1), 2));
            end
        % top
            top = 0;
            t_t = 0;
            if(i - 1 > 0)
            	t_t = t_t + 1;
                top = squeeze(SCO_test(real_goal(i, j), real_goal(i - 1, j), 1));
            end
            dist_vec(real_goal(i, j)) = (left + right + top + bottom)/(t_l + t_r + t_t + t_b);
        
            dist_vec_trb(real_goal(i, j)) = (right + top + bottom)/(t_r + t_t + t_b);
            dist_vec_lrb(real_goal(i, j)) = (left + right + bottom)/(t_l + t_r + t_b);
            dist_vec_tlb(real_goal(i, j)) = (left + top + bottom)/(t_l + t_t + t_b);
            dist_vec_tlr(real_goal(i, j)) = (left + right + top)/(t_l + t_r + t_t);

            dist_vec_lr(real_goal(i, j)) = (left + right)/(t_l + t_r);
            dist_vec_lt(real_goal(i, j)) = (left + top)/(t_l + t_t);
            dist_vec_lb(real_goal(i, j)) = (left + bottom)/(t_l + t_b);
            dist_vec_tr(real_goal(i, j)) = (top + right)/(t_t + t_r);
            dist_vec_tb(real_goal(i, j)) = (top + bottom)/(t_t + t_b);
            dist_vec_rb(real_goal(i, j)) = (bottom + right)/(t_b + t_r);
        end
    end
%

    connection_mat = zeros(numbOfParts);
    for i = 1:size(real_goal, 1)
        for j = 1:size(real_goal, 2)  
            if(j - 1 > 0)
                connection_mat(real_goal(i, j), real_goal(i, j - 1)) = 1;
                connection_mat(real_goal(i, j - 1), real_goal(i, j)) = 1;
            end
            if(i - 1 > 0)
                connection_mat(real_goal(i, j), real_goal(i - 1, j)) = 1;
                connection_mat(real_goal(i - 1, j), real_goal(i, j)) = 1;
            end
            if(j + 1 < size(real_goal, 2))
                connection_mat(real_goal(i, j), real_goal(i, j + 1)) = 1;
                connection_mat(real_goal(i, j + 1), real_goal(i, j)) = 1;
            end
            if(i + 1 < size(real_goal, 1))
                connection_mat(real_goal(i, j), real_goal(i + 1, j)) = 1;
                connection_mat(real_goal(i + 1, j), real_goal(i, j)) = 1;
            end
    	end
    end

    connection_mat_2 = (connection_mat .* nn4Mat_test) > 0;
    connection_mat_2_X = (connection_mat .* nn4Mat_test) > 0;

    real_goal_1 = real_goal;
    [rg_1, rg_2] = size(real_goal);

    for i = 1:numbOfParts
        [x_c, y_c] = find(real_goal == i);
        if(dist_vec(i) > 1.5 * median(dist_vec(dist_vec >= 0)))
            connection_mat_2(i, :) = 0;
            connection_mat_2(:, i) = 0;
            real_goal_1(x_c, y_c) = 0;
        end
        if(dist_vec_trb(i) > 1.5 * median(dist_vec_trb(dist_vec_trb >= 0)))
            if(x_c > 1)
                connection_mat_2_X(i, real_goal(x_c-1, y_c)) = 0;
            end
            if(y_c < rg_2)
                connection_mat_2_X(i, real_goal(x_c, y_c + 1)) = 0;
            end
            if(x_c < rg_1)
                connection_mat_2_X(i, real_goal(x_c+1, y_c)) = 0;
            end
        end
    
        if( dist_vec_lrb(i) > 1.5 * median(dist_vec_lrb(dist_vec_lrb >= 0)))
            if(y_c > 1)
                connection_mat_2_X(i, real_goal(x_c, y_c-1)) = 0;
            end
            if(y_c < rg_2)
                connection_mat_2_X(i, real_goal(x_c, y_c + 1)) = 0;
            end
            if(x_c < rg_1)
                connection_mat_2_X(i, real_goal(x_c+1, y_c)) = 0;
            end
        end
    
        if(dist_vec_tlb(i) > 1.5 * median(dist_vec_tlb(dist_vec_tlb >= 0)))
            if(x_c > 1)
                connection_mat_2_X(i, real_goal(x_c-1, y_c)) = 0;
            end
            if(y_c > 1)
                connection_mat_2_X(i, real_goal(x_c, y_c-1)) = 0;
            end
            if(x_c > 1)
                connection_mat_2_X(i, real_goal(x_c-1, y_c)) = 0;
            end
            if(y_c > 1)
                connection_mat_2_X(i, real_goal(x_c, y_c-1)) = 0;
            end
        end
    
        if(dist_vec_tlr(i) > 1.5 * median(dist_vec_tlr(dist_vec_tlr >= 0)))
            if(x_c > 1)
                connection_mat_2_X(i, real_goal(x_c-1, y_c)) = 0;
            end
            if(y_c > 1)
                connection_mat_2_X(i, real_goal(x_c, y_c-1)) = 0;
            end
            if(y_c < rg_2)
                connection_mat_2_X(i, real_goal(x_c, y_c + 1)) = 0;
            end
        end
    end

    connection_mat_2_X = (connection_mat_2_X + connection_mat_2_X') > 0;
    X = (connection_mat_2 + connection_mat_2_X)/2;
    [S, c_vals] = graphconncomp(sparse(X));

    x = find(c_vals == mode(c_vals));


    real_goal_rem = real_goal;

    for i = 1:numbOfParts
        if(~sum(x == i))
            real_goal_rem(real_goal == i) = 0;
        end
    end
    median_dist_vec = median(dist_vec);
end

