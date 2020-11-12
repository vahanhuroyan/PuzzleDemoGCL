%% use rotation solution to check if the matches are good

function good = check_match_rot(info,rot)

num = size(info,1);

%% The number of ccw rotations performed
% mat1 = [1 13 9 5; 8 4 16 12; 11 7 3  15; 14 10 6 2];
% mat2 = [2 14 10 6; 5 1 13 9; 12 8 4 16; 15 11 7 3];
% mat3 = [3 15 11 7; 6 2 10 14; 9 5 1  13; 16 12 8 4];
% mat4 = [4 16 12 8; 7 3 15 11; 14 6 2 10; 13 9 5 1];

%% The number of ccw rotations to perform
mat1 = [ 1 5 9 13; 14 2 6 10; 11 15 3 7; 8 12 16 4];
mat2 = [2 6 10 14; 15 3 7 11; 12 16 4 8; 5 9 13 1];
mat3 = [3 7 11 15; 16 4 8 12; 9 13 1 5; 6 10 14 2];
mat4 = [4 8 12 16; 13 1 5 9; 10 14 2 6; 7 11 15 3];

good = zeros(num,1);

for i = 1:num
   
    r1 = rot(info(i,1));
    r2 = rot(info(i,2));
    
    config = info(i,4);
    
    if(mat1(r1,r2) == config || ...
       mat2(r1,r2) == config || ...
       mat3(r1,r2) == config || ...
       mat4(r1,r2) == config)
        good(i) = 1;
    end
    
end