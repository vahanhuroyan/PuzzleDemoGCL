%% modify the info based on the rotation result from MRF
% according to the rotation of the pieces and matcing configuration,
% recover the matching configuration for LP
% if the rotation and matching is not consistent, then delete the pair

function [info,info_bk,del] = info_update(info,rot,flag)

info_bk = info;
num = size(info,1);

if(flag)
    
    %% The number of ccw rotations performed
    mat1 = [1 13 9 5; 8 4 16 12; 11 7 3  15; 14 10 6 2];
    mat2 = [2 14 10 6; 5 1 13 9; 12 8 4 16; 15 11 7 3];
    mat3 = [3 15 11 7; 6 2 10 14; 9 5 1  13; 16 12 8 4];
    mat4 = [4 16 12 8; 7 3 15 11; 14 6 2 10; 13 9 5 1];
    
else
    
    %% The number of ccw rotations to perform
    mat1 = [ 1 5 9 13; 14 2 6 10; 11 15 3 7; 8 12 16 4];
    mat2 = [2 6 10 14; 15 3 7 11; 12 16 4 8; 5 9 13 1];
    mat3 = [3 7 11 15; 16 4 8 12; 9 13 1 5; 6 10 14 2];
    mat4 = [4 8 12 16; 13 1 5 9; 10 14 2 6; 7 11 15 3];
    
end

r1 = rot(info(:,1));
r2 = rot(info(:,2));
config = info(:,4);

del = [];
for i = 1:num
       
    if(mat1(r1(i),r2(i)) == config(i))
        info(i,4) = 1;
    elseif(mat2(r1(i),r2(i)) == config(i))
        info(i,4) = 2;
    elseif(mat3(r1(i),r2(i)) == config(i))        
        info(i,4) = 3;
    elseif(mat4(r1(i),r2(i)) == config(i))
        info(i,4) = 4;        
    else
        del = [del;i];
    end
    
end

info(del,:) = [];
info_bk(del,:) = [];
