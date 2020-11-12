%
% Written by Vahan Huroyan
%
function [ conn_comp ] = update_weights( solved_grid, nn4Mat_test, numbOfParts)
%UPDATE_WEIGHTS Summary of this function goes here
%   Detailed explanation goes here

    rows_solved_1 = size(solved_grid, 1);
    cols_solved_1 = size(solved_grid, 2);

    conn_comp = zeros(numbOfParts);

    for i = 1:rows_solved_1
        for j = 1:cols_solved_1
            neighbors_cur = [solved_grid(i, min(j+1, cols_solved_1)) solved_grid(i, max(j-1, 1)) solved_grid(min(i+1, rows_solved_1), j) solved_grid(max(i-1, 1), j)];
            neighbors_cur(neighbors_cur == solved_grid(i, j)) = [];
%           disp('--')
            for t = 1:length(neighbors_cur)
                if(nn4Mat_test(solved_grid(i, j), neighbors_cur(t)))
                    conn_comp(solved_grid(i, j), neighbors_cur(t)) = 1;
                end
            end
        end
    end
 
end

