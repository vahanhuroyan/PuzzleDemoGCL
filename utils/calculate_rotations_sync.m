function [ rotPatches, rotsNum, rotations ] = calculate_rotations_sync( nn4Mat, rot_mat, Patches)
%CALCULATE_LOCATIONS Summary of this function goes here
%   Detailed explanation goes here


    numbOfParts = size(nn4Mat, 1);
    rel_rot_mat = rot_mat .* nn4Mat;

    
%     [rotations, ~] = svds(rel_rot_mat, 1, 0);
    [rotations, ~] = eig(rel_rot_mat);
    rotations = rotations(:, end);
    % round the angles
    [angles, rotsNum] = roundAngles( rotations );

    rotPatches = cell(1, numbOfParts);
    for i = 1:numbOfParts
        switch rotsNum(i);
            case 1
                rotPatches{i} = rot90(rot90(rot90(Patches{i})));
            case 2
                rotPatches{i} = rot90(rot90(Patches{i}));
            case 3
                rotPatches{i} = rot90(Patches{i});
            otherwise
                rotPatches{i} = Patches{i};
        end
    end
    
end

