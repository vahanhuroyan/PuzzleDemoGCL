%% generate the pairwise scores for all possible rotations
function SCO_all = get_all_SCO(SCO)

  num = size(SCO,1);
  SCO_all = Inf(4*num,4*num,4);
  SCO_all(1:num,1:num,:) = SCO(:,:,1:4);

  vec1 = 1:16;
  vec2 = [14 15 16 13 2 3 4 1 6 7 8 5 10 11 12 9];
  vec3 = [11 12 9 10 15  16 13 14 3 4 1 2 7 8 5 6];
  vec4 = [8 5 6 7 12 9 10 11 16 13 14 15 4 1 2 3];

  vec = [vec1;vec2;vec3;vec4];
  
  for i = 1:4
      for j = 1:4          
          SCO_all((i-1)*num+1:i*num,(j-1)*num+1:j*num,:) = SCO(:,:,vec(i,4*(j-1)+1:4*j));          
      end      
  end
  
end

% P1:0 P2:0 1 2 3 4
% P1:0 P2:90 5 6 7 8
% P1:0 P2:180 9 10 11 12
% P1:0 P2:270 13 14 15 16

% P1:90 P2:0 14 15 16 13
% P1:90 P2:90 2 3 4 1
% P1:90 P2:180 6 7 8 5
% P1:90 P2:270 10 11 12 9

% P1:180 P2:0 11 12 9 10
% P1:180 P2:90 15 16 13 14 
% P1:180 P2:180 3 4 1 2
% P1:180 P2:270 7 8 5 6

% P1:270 P2:0 8 5 6 7
% P1:270 P2:90 12 9 10 11
% P1:270 P2:180 16 13 14 15
% P1:270 P2:270 4 1 2 3