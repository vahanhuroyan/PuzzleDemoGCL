%% get the mixed integer program formulation for solving rotations
function [f,A,b,Aeq,beq] = mip_from_patch_and_weight_rot(SCO,info)

m = size(info,1); % oberservation
n = size(SCO,1); % number of pieces

A = zeros(m,n);  % n for r, maybe should switch to sparse matrix
ind1 = sub2ind([m,n],(1:m)',info(:,1));
ind2 = sub2ind([m,n],(1:m)',info(:,2));
% diff = mod(info(:,4)-1,4);
diff = floor((info(:,4)-1)/4);

val = ones(m,1);
A(ind1) = val;
A(ind2) = -val;

b = diff;

%% add 2 mx1 auxilary variable g and h, and mx1 variable z(integer)
B = [-eye(m) eye(m) 4*eye(m)];
A = [A B]; % m*(n+3m)

%% one zero mean constraint to be added to A
A_add = [ones(1,n) zeros(1,3*m)];  %1x(n+3m)
b_add = 0;

Aeq = [A;A_add]; %(m+1)*(n+3m);
beq = [b;b_add]; %(m+1)*1
beq = double(beq);

%% objective function
w = info(:,3);
f = [zeros(1,n) w' w' zeros(1,m)]';
f = double(f);

%% inequality constraint
A = zeros(2*m,n+3*m); %2m*(n+3m)
A(1:m,n+1:n+m) = eye(m);
A(m+1:2*m,n+m+1:n+2*m) = eye(m);
A = -A; b = zeros(2*m,1);

%% integer constraint on Z


%% make matrices sparse
A = sparse(A);
Aeq = sparse(Aeq);