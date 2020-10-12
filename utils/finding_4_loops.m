% function [ nn4Mat,  rot_mat_out, diag_nb, true_nb] = finding_4_loops( nn4Mat, rot_mat, trueVals )
function [ nn4Mat,  rot_mat_out, diag_nb] = finding_4_loops( nn4Mat, rot_mat )
   
%   Detailed explanation goes here
    rot_mat_out = rot_mat;
    current_neighbors_1 = {};
    current_neighbors_2 = {};
    numbOfParts = size(nn4Mat, 1);
%     current_neighbors_tr = {};
% find 1-neighbours of all pieces
    for i = 1:numbOfParts
        current_neighbors_1{i} = find(nn4Mat(:, i));
%         current_neighbors_tr{i} = find(trueVals(:, i));
    end
% find 2-neighbours of all pieces
    for i = 1:numbOfParts
        current_neighbors_2{i} = [];
        for j = 1:length(current_neighbors_1{i})
            current_neighbors_2{i} = [current_neighbors_2{i} find(nn4Mat(current_neighbors_1{i}(j), :))];
        end
        current_neighbors_2{i} = unique(current_neighbors_2{i});
        current_neighbors_2{i}(current_neighbors_2{i} == i) = [];
    end

    diag_nb = zeros(numbOfParts);
%     true_nb = zeros(numbOfParts);
    for i = 1:numbOfParts
        for j = 1:length(current_neighbors_2{i})
            if(length(intersect(current_neighbors_1{i}, current_neighbors_1{current_neighbors_2{i}(j)})) == 2);
                diag_nb(i, current_neighbors_2{i}(j)) = 1;
            end
        end    
%         for j = (i+1):numbOfParts
%             if(length(intersect(current_neighbors_tr{i}, current_neighbors_tr{j})) == 2)
%                  true_nb(i, j) = 1;
%             end
%         end
    end

    diag_nb = (diag_nb + diag_nb')/2;
%     true_nb = true_nb + true_nb';

    for i = 1:numbOfParts
        for j = 1:numbOfParts
            if(diag_nb(i, j))
                x = intersect(current_neighbors_1{i}, current_neighbors_1{j});
                if(rot_mat(x(1), j) * rot_mat(i, x(1))/abs(rot_mat(x(1), j) * rot_mat(i, x(1))) == rot_mat(x(2), j) * rot_mat(i, x(2))/abs(rot_mat(x(2), j) * rot_mat(i, x(2))));
%             if(rot_mat(x(1), j) * rot_mat(i, x(1)) == rot_mat(x(2), j) * rot_mat(i, x(2)));
%                     disp('***');
                    rot_mat_out(i, j) =  rot_mat(x(1), j) * rot_mat(i, x(1));
                else
%                     disp(rot_mat(x(1), j) * rot_mat(i, x(1)));
%                     disp(rot_mat(x(2), j) * rot_mat(i, x(2)));
                    disp([int2str(i) '---' int2str(x(1)) '****' int2str(j) '---' int2str(x(2))]);
                    diag_nb(i, j) = 0;
                    nn4Mat(x(1), i) = nn4Mat(x(1), i)/2;
                    nn4Mat(i, x(1)) = nn4Mat(i, x(1))/2;
                    nn4Mat(x(1), j) = nn4Mat(x(1), j)/2;
                    nn4Mat(j, x(1)) = nn4Mat(j, x(1))/2;
                    nn4Mat(x(2), i) = nn4Mat(x(2), i)/2;
                    nn4Mat(i, x(2)) = nn4Mat(i, x(2))/2;
                    nn4Mat(x(2), j) = nn4Mat(x(2), j)/2;
                    nn4Mat(j, x(2)) = nn4Mat(j, x(2))/2;
                end
            end
        end
    end
    
    nn4Mat = nn4Mat / 1.5;
    for i = 1:numbOfParts
        for j = 1:numbOfParts
            if(diag_nb(i, j))
                X = intersect(find(nn4Mat(i, :)), find(nn4Mat(j, :)));
                if(length(X) == 2)
                        nn4Mat(i, X(1)) = 1; nn4Mat(X(1), i) = 1;
                        nn4Mat(i, X(2)) = 1; nn4Mat(X(2), i) = 1;
                        nn4Mat(j, X(1)) = 1; nn4Mat(X(1), j) = 1;
                        nn4Mat(j, X(2)) = 1; nn4Mat(X(2), j) = 1;
                end
            end
        end
    end
%     nn4Mat_out = nn4Mat + diag_nb;
end

