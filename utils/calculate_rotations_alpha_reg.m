function [ rotPatches, rotsNum, rotations ] = calculate_rotations_alpha_reg( nn4Mat, rot_mat, Patches)
%CALCULATE_LOCATIONS Summary of this function goes here
%   Detailed explanation goes here
    numbOfParts = size(nn4Mat, 1);
    
%     lMat = rot_mat .* nn4Mat;
%     D = diag(sum(abs(lMat), 2)); 
%     lMat1 = D - lMat;   
%     C = inv(sqrtm(D)) * lMat1 * inv(sqrtm(D));
%     A = inv(D) * lMat1;

    alpha = 1;
    P = diag(sum(nn4Mat,2).^(-1/alpha));
    W_2 = P * nn4Mat * P;
    D = diag(sum(W_2, 2).^(-1)) ;
    A_alpha = D*W_2;
    C = rot_mat .*A_alpha;
    
    [U, ~] = svds(C, 1, 0);
    U = inv(sqrtm(D)) * U ;    
    rotations = U;

    % [U, ~, ~] = eig(lMat);
    % rotations = U(:, end);

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

