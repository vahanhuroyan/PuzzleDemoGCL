function [rotMat, posMat, weights] = pairwiseRotPosWeight_nn(dist_mat)   
    
	numbOfParts = size(dist_mat, 1);
    weights = zeros(numbOfParts);
    rotMat = zeros(numbOfParts);
    posMat = zeros(numbOfParts);
    for i = 1:numbOfParts-1
        for j = (i+1):numbOfParts
            [weights(i, j), min_ind] = min(dist_mat(i, j, :));
            switch floor((min_ind - 1) / 4);
                case 0
                    rotMat(i, j) = 1;
                case 1
                    rotMat(i, j) = 0+1i;
                case 2
                    rotMat(i, j) = -1;
                case 3
                    rotMat(i, j) = 0-1i;
                otherwise
                    rotMat(i, j) = 0;
            end
            
            switch rem((min_ind - 1), 4);
                case 0
                    posMat(i, j) = 1;
                case 1
                    posMat(i, j) = 0+1i;
                case 2
                    posMat(i, j) = -1;
                case 3
                    posMat(i, j) = 0-1i;
                otherwise
                    posMat(i, j) = 0;
            end
            
        end
    end
    
    for i = 1:numbOfParts
        for j = 1:numbOfParts
        	[~, min_ind] = min(dist_mat(i, j, :));
            switch rem((min_ind - 1), 4);
                case 0
                    posMat(i, j) = 1;
                case 1
                    posMat(i, j) = 0+1i;
                case 2
                    posMat(i, j) = -1;
                case 3
                    posMat(i, j) = 0-1i;
                otherwise
                    posMat(i, j) = 0;
            end
        end
    end
	weights = weights + weights';
	rotMat = rotMat + rotMat';
end
