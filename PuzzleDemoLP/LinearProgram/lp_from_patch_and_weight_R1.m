%% get the linear program formulation from pairwise match result
function [f,A,b,Aeq,beq] = lp_from_patch_and_weight_R1(SCO,info,nr)

m = size(info,1); % oberservation
n = size(SCO,1); % number of pieces
A = zeros(m,n);  % n for x, maybe should switch to sparse matrix
ind1 = sub2ind([m,n],(1:m)',info(:,1));
ind2 = sub2ind([m,n],(1:m)',info(:,2));
delta_ind = info(:,4) == 2 | info(:,4) == 4;
flip_ind = info(:,4) == 3 | info(:,4) == 2;
val = ones(m,1); val(flip_ind) = -1;
A(ind1) = val;
A(ind2) = -val;
% A(delta_ind,:) = A(delta_ind,:)*1/nr;
b = ones(m,1);
b(delta_ind) = nr;
% %% sparse A
% A = sparse(([1:m 1:m])',[info(:,1)+delta_ind*n;info(:,2)+delta_ind*n],[val;-val],m,2*n);

%% add 2 mx1 auxilary variable g and h
B = [-eye(m) eye(m)];
A = [A B]; % m*(n+2m)

%% two rows of zeros mean constraints to be added to A
A_add = [ones(1,n) zeros(1,2*m)];  %1x(n+2m)
% b_add = 0;
b_add = (1+n)/2*n;
Aeq = [A;A_add]; %(m+1)*(n+2m);
beq = [b;b_add]; %(m+1)*1

%% objective function
w = info(:,3);
% w(delta_ind) = w(delta_ind)*1/nr;
f = [zeros(1,n) w' w']';
f = double(f);

%% inequality constraint
A = zeros(2*m,n+2*m); %2m*(n+2m)
A(1:m,n+1:n+m) = eye(m);
A(m+1:2*m,n+m+1:n+2*m) = eye(m);
A = -A; b = zeros(2*m,1);