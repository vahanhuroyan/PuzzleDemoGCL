function [large_Image] = printLargeImage( rgbParts, cols, rows, order, patch_distance )
%   This function takes patches and the order and creates the solved puzzle
    if(nargin < 5)
    	patch_distance = 0;
    end
    rgbParts = rgbParts(order);
%     rows = length(rgbParts) / cols;
    h_size = size(rgbParts{1}, 1);
    w_size = size(rgbParts{1}, 2);
    width = cols * w_size + (cols + 1) * patch_distance;
    height = rows * h_size + (rows + 1) * patch_distance;
    
    % make background white
%     large_Image = 65536/0.7 * ones(height, width, 3);
    large_Image = 65536/1.1 * ones(height, width, 3);
%     large_Image = 160 * ones(height, width, 3);
    for i = 1:rows
        for j = 1:cols
            large_Image(((i - 1) * (h_size + patch_distance) + patch_distance + 1):(i * (h_size + patch_distance)) , ...
            ((j - 1) * (w_size + patch_distance) + patch_distance + 1):(j * (w_size + patch_distance)), :) = rgbParts{(j - 1) * rows + i};
        end
    end
    disp(size(large_Image))
    disp(height)
    disp(width)
    large_Image = large_Image((patch_distance+1):(height-patch_distance), (patch_distance+1):(width-patch_distance), :);
end

