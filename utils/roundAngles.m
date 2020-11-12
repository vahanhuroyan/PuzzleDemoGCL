%
% Written by Vahan Huroyan
%
function [ angles, rotsNum ] = roundAngles( rotations )
%   This function takes the eigenvector of GCL that describes the 
%   rotation information of all patches and returnes the angles 

    angles = angle(rotations);
    for i = 1:size(angles, 1)
        if(angles(i) < 0)
            angles(i) = angles(i) + 2 * pi;
        end
    end
    
    % making rotation angles 0, pi/2, pi, 3*pi/2
    rotsNum = zeros(size(angles));
    for i = 1:size(angles, 1)
        if(angles(i) < pi / 2)
            if(angles(i) < pi / 2 - angles(i))
                angles(i) = 0;
                rotsNum(i) = 0;
            else
                angles(i) = pi / 2;
                rotsNum(i) = 1;
            end
        else if(angles(i) < pi)
            if(angles(i) - pi / 2 < pi - angles(i))
                angles(i) = pi / 2;
                rotsNum(i) = 1;
            else
                angles(i) = pi;
                rotsNum(i) = 2;
            end
            else
                if(angles(i) < 3*pi/2)
                    if(angles(i) - pi < 3*pi/2 - angles(i))
                        angles(i) = pi;
                        rotsNum(i) = 2;
                    else
                        angles(i) = 3*pi/2;
                        rotsNum(i) = 3;
                    end
                else
                    if(angles(i) - 3*pi/2 < 2*pi - angles(i))
                        angles(i) = 3*pi/2;
                        rotsNum(i) = 3;
                    else
                        angles(i) = 0;
                        rotsNum(i) = 0;
                    end
                end
            end
        end
    end
end

