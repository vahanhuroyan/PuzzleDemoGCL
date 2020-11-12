%
% Written by Vahan Huroyan
%

function [error_val] = calculate_error(SCO_final, real_goal)
    error_val = 0;
    
    for i = 1:size(real_goal, 1)
        for j = 1:size(real_goal, 2)
            % left
            if(j - 1 > 0)
                error_val = error_val + SCO_final(real_goal(i, j), real_goal(i, j - 1), 4);
            end
            % bottom
            if(i + 1 < size(real_goal, 1))
                error_val = error_val + SCO_final(real_goal(i, j), real_goal(i + 1, j), 3);
            end
            % right
            if(j + 1 < size(real_goal, 2))
                error_val = error_val + SCO_final(real_goal(i, j), real_goal(i, j + 1), 2);
            end
            % top
            if(i - 1 > 0)
                error_val = error_val + SCO_final(real_goal(i, j), real_goal(i - 1, j), 1);
            end
        end
    end
    
end

