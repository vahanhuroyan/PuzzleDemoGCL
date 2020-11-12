%% use ground truth to check if matches are correct
function [good,good2] = check_match(info,ppp,rot,nr,flag)

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

good = zeros(num,1);

%% check if the corresponding one(interchange piece one and piece two) is good or not
cor_map = [3 4 1 2 16 13 14 15 9 10 11 12 6 7 8 5];
good2 = zeros(num,1);

for i = 1:num
    
    r1 = rot(info(i,1));
    r2 = rot(info(i,2));
    
    p1 = ppp(info(i,1));
    p2 = ppp(info(i,2));
    
    config = info(i,4);
    %
    %     if((p2+1 == p1 && mat1(r1,r2) == config) || ...
    %             (p2-nr ==p1 && mat2(r1,r2) == config) || ...
    %             (p2-1 ==p1 && mat3(r1,r2) == config) || ...
    %             (p2+nr ==p1 && mat4(r1,r2) == config))
    %         good(i) = 1;
    %     end
    
    if((my_equal(p2+1,p1) && mat1(r1,r2) == config) || ...
            (my_equal(p2-nr,p1) && mat2(r1,r2) == config) || ...
            (my_equal(p2-1,p1) && mat3(r1,r2) == config) || ...
            (my_equal(p2+nr,p1) && mat4(r1,r2) == config))
        good(i) = 1;
    end
    
    row_i = [info(i,2) info(i,1) info(i,3) cor_map(config)];
    if(ismember(row_i,info,'rows'));
        good2(i) = 1;
    end
    
end

end

function test = my_equal(x1,x2)
    test = abs(x1-x2) < 0.0001;
end