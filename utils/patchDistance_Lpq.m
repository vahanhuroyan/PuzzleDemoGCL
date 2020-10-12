function [ distance, rot ] = patchDistance_Lpq( patch1, patch2 , p, q )
%   PATCHDISTANCEL_PQ Summary of this function goes here
%   Detailed explanation goes here
    distanceVec = zeros(16, 1);
    patch1 = double(patch1);
    patch2 = double(patch2);
    
    distanceVec(1) = sum(sum((abs(patch1(:, end, :) - patch2(:,1,:))).^p)).^(q/p);

    distanceVec(5) = sum(sum((abs(patch1(1, :, :) - patch2(end,:,:))).^p)).^(q/p);
    
    distanceVec(9) = sum(sum((abs(patch1(:, 1, :) - patch2(:,end,:))).^p)).^(q/p);
   
    distanceVec(13) = sum(sum((abs(patch1(end, :, :) - patch2(1,:,:))).^p)).^(q/p);

                
                
    patch2 = rot90(patch2);
    distanceVec(2) = sum(sum((abs(patch1(:, end, :) - patch2(:,1,:))).^p)).^(q/p);
    
    distanceVec(6) = sum(sum((abs(patch1(1, :, :) - patch2(end,:,:))).^p)).^(q/p);
            
    distanceVec(10) = sum(sum((abs(patch1(:, 1, :) - patch2(:,end,:))).^p)).^(q/p);
                
    distanceVec(14) = sum(sum((abs(patch1(end, :, :) - patch2(1,:,:))).^p)).^(q/p);
                
                
    patch2 = rot90(patch2);
    distanceVec(3) = sum(sum((abs(patch1(:, end, :) - patch2(:,1,:))).^p)).^(q/p);
    
    distanceVec(7) = sum(sum((abs(patch1(1, :, :) - patch2(end,:,:))).^p)).^(q/p);
                 
    distanceVec(11) = sum(sum((abs(patch1(:, 1, :) - patch2(:,end,:))).^p)).^(q/p);
                
    distanceVec(15) = sum(sum((abs(patch1(end, :, :) - patch2(1,:,:))).^p)).^(q/p);
            
    patch2 = rot90(patch2);
    distanceVec(4) = sum(sum((abs(patch1(:, end, :) - patch2(:,1,:))).^p)).^(q/p);
    
    distanceVec(8) = sum(sum((abs(patch1(1, :, :) - patch2(end,:,:))).^p)).^(q/p);
    
    distanceVec(12) = sum(sum((abs(patch1(:, 1, :) - patch2(:,end,:))).^p)).^(q/p);
    
    distanceVec(16) = sum(sum((abs(patch1(end, :, :) - patch2(1,:,:))).^p)).^(q/p);    
    
    [distance, rotNumber] = min(distanceVec);
    
    switch rem(rotNumber, 4);
        case 0
            rot = 0-1i;
        case 1
            rot = 1;
        case 2
            rot = 0+1i;
        case 3
            rot = -1;
    otherwise
        rot = 0;
    end
    %disp(sort(distanceVec));

end

