%% SCO_All_test modification
%% in case of unknown rotations, change the distance between the same pieces
%% (coming from the same pieces but with different rotation) to inf
function SCO = SCO_modify(SCO)

anum = size(SCO,1);
bnum = anum/4;

for i = 1:4
    for j = 1:4        
        for k = 1:4
            SCO_temp = SCO((i-1)*bnum+1:i*bnum,(j-1)*bnum+1:j*bnum,k);
            SCO_temp(logical(eye(bnum))) = inf;
            SCO((i-1)*bnum+1:i*bnum,(j-1)*bnum+1:j*bnum,k) = SCO_temp;
        end
    end
end