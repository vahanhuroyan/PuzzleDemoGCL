%% use lp and rotation result to check if the matches are good

function good = check_match_lp(info,x,rot,n)

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

xx = x(1:n);
yy = x(1+n:2*n);

for i = 1:num
    
    r1 = rot(info(i,1));
    r2 = rot(info(i,2));
    
    x1 = xx(info(i,1));
    x2 = xx(info(i,2));
    
    y1 = yy(info(i,1));
    y2 = yy(info(i,2));
    
    config = info(i,4);
        
%     if((x2+1 == x1 && y2 == y1 && mat1(r1,r2) == config) || ...
%             (x2 == x1 && y2-1 == y1 && mat2(r1,r2) == config) || ...
%             (x2-1 == x1 && y2 == y1 && mat3(r1,r2) == config) || ...
%             (x2 == x1 && y2+1 == y1 && mat4(r1,r2) == config))
%         good(i) = 1;
%     end

    if((my_equal(x2+1,x1) && my_equal(y2,y1) && mat1(r1,r2) == config) || ...
            (my_equal(x2,x1) && my_equal(y2-1,y1) && mat2(r1,r2) == config) || ...
            (my_equal(x2-1,x1) && my_equal(y2,y1) && mat3(r1,r2) == config) || ...
            (my_equal(x2,x1) && my_equal(y2+1,y1) && mat4(r1,r2) == config))
        good(i) = 1;
    end
    
end

end

function test = my_equal(x1,x2)
    test = abs(x1-x2) < 0.0001;
end