function [SCO_test] = reorder_SCO(SCO_cr, rotsNum)
%  based on the calculated rotations, we update the relative MGC values
%  between patches

    numbOfParts = size(rotsNum, 1);
    SCO_test = SCO_cr;

    possible_perms = zeros(16);

    possible_perms(1, :) = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];
    possible_perms(2, :) = [13 14 15 16 1 2 3 4 5 6 7 8 9 10 11 12];
    possible_perms(3, :) = [9 10 11 12 13 14 15 16 1 2 3 4 5 6 7 8];
    possible_perms(4, :) = [5 6 7 8 9 10 11 12 13 14 15 16 1 2 3 4];

    possible_perms(5, :) = [8 5 6 7 12 9 10 11 16 13 14 15 4 1 2 3];
    possible_perms(6, :) = [4 1 2 3 8 5 6 7 12 9 10 11 16 13 14 15];
    possible_perms(7, :) = [16 13 14 15 4 1 2 3 8 5 6 7 12 9 10 11];
    possible_perms(8, :) = [12 9 10 11 16 13 14 15 4 1 2 3 8 5 6 7];

    possible_perms(9, :) = [11 12 9 10 15 16 13 14 3 4 1 2 7 8 5 6];
    possible_perms(10, :) = [7 8 5 6 11 12 9 10 15 16 13 14 3 4 1 2];
    possible_perms(11, :) = [3 4 1 2 7 8 5 6 11 12 9 10 15 16 13 14];
    possible_perms(12, :) = [15 16 13 14 3 4 1 2 7 8 5 6 11 12 9 10];

    possible_perms(13, :) = [14 15 16 13 2 3 4 1 6 7 8 5 10 11 12 9];
    possible_perms(14, :) = [10 11 12 9 14 15 16 13 2 3 4 1 6 7 8 5];
    possible_perms(15, :) = [6 7 8 5 10 11 12 9 14 15 16 13 2 3 4 1];
    possible_perms(16, :) = [2 3 4 1 6 7 8 5 10 11 12 9 14 15 16 13];

    pair_rot_numb = zeros(4, 4);
    for i = 1:4
        for j = 1:4
            pair_rot_numb(i, j) = 4*(i-1) + j;
        end
    end

    for i = 1:numbOfParts
        for j = 1:numbOfParts
            SCO_test(i, j, :) = SCO_test(i, j, possible_perms(pair_rot_numb(rotsNum(i) + 1, rotsNum(j) + 1), :));
        end
    end
end

