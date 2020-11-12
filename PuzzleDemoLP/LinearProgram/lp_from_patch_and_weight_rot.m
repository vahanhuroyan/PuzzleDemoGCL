%% get the linear program formulation for solving rotations(use complex numbers as rotation representation)
function [f,A,b,Aeq,beq] = lp_from_patch_and_weight_rot(SCO,info)

m = size(info,1); % oberservation
n = size(SCO,1); % number of pieces

A1 = zeros(m,2*n);  
A2 = zeros(m,2*n);
ind1 = sub2ind([m,n],(1:m)',info(:,1));
ind2 = sub2ind([m,n],(1:m)',info(:,2));

diff = floor((info(:,4)-1)/4);

delta_x = [0 0 0 0; m*n m*n m*n m*n];
delta_y = [0 m*n 0 m*n; m*n 0 m*n 0];
flip = [-1 1 1 -1; -1 -1 1 1];

delta_x = delta_x';
delta_y = delta_y';
flip = flip';

A1(ind1+delta_x(diff+1,1)) = 1;
A1(ind2+delta_y(diff+1,1)) = flip(diff+1,1);

A2(ind1+delta_x(diff+1,2)) = 1;
A2(ind2+delta_y(diff+1,2)) = flip(diff+1,2);

A = [A1;A2];
b = zeros(2*m,1);

%% add 2 2mx1 auxilary variable g and h
B = [-eye(2*m) eye(2*m)];
A = [A B]; % 2m*(2n+4m)

%% fix the rotation of the first piece
A_add = [1 zeros(1,2*n+4*m-1);zeros(1,n) 1 zeros(1,n+4*m-1)];
b_add = [1;1];

Aeq = [A;A_add];
beq = [b;b_add];

%% objective function
w = [info(:,3);info(:,3)];
f = [zeros(1,2*n) w' w']';
f = double(f);

%% inequality constraint
A = zeros(4*m,4*m+2*n); %4m*(4m+2n)
A(1:2*m,2*n+1:2*n+2*m) = eye(2*m);
A(2*m+1:4*m,2*n+2*m+1:2*n+4*m) = eye(2*m);
A = -A; b = zeros(4*m,1);

A = sparse(A);
Aeq = sparse(Aeq);

end