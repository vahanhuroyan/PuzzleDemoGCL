%% get the linear program formulation from pairwise match result
function [f,A,b,Aeq,beq] = lp_from_patch_and_weight(n,info,varargin)

[method,fix_pos,fix_val] = getPrmDflt(varargin,{'method', 'zero_mean','fix_pos',[], ... 
    'fix_val',[]}, 1);

%% do some check on info to make sure info(:,4) has only four possible values
if(any(setdiff(unique(info(:,4)),(1:4)')))
   error('info has some configuration beyond 1 to 4, possibly are outliers'); 
end

m = size(info,1); % oberservation

A1 = zeros(m,2*n);  % 2*n for x and y, maybe should switch to sparse matrix
A2 = zeros(m,2*n);  % 2*n for x and y, maybe should switch to sparse matrix

ind1 = sub2ind([m,n],(1:m)',info(:,1));
ind2 = sub2ind([m,n],(1:m)',info(:,2));
delta_ind = info(:,4) == 2 | info(:,4) == 4;
flip_ind = info(:,4) == 3 | info(:,4) == 2;

%% one part
ind1_one = ind1 + delta_ind*m*n;
ind2_one = ind2 + delta_ind*m*n;
val = ones(m,1); val(flip_ind) = -1;
A1(ind1_one) = val;
A1(ind2_one) = -val;
b1 = ones(m,1);

%% zero part
delta_ind_zero = ~delta_ind;
ind1_zero = ind1 + delta_ind_zero*m*n;
ind2_zero = ind2 + delta_ind_zero*m*n;
A2(ind1_zero) = val;
A2(ind2_zero) = -val;
b2 = zeros(m,1);

A = [A1;A2];
b = [b1;b2];

% %% sparse A
% A = sparse(([1:m 1:m])',[info(:,1)+delta_ind*n;info(:,2)+delta_ind*n],[val;-val],m,2*n);

%% add 2 2mx1 auxilary variable g and h
B = [-eye(2*m) eye(2*m)];
A = [A B]; % 2m*(2n+4m)

%% two rows of zeros mean constraints to be added to A

switch method
    case 'zero_mean' % add the zero mean constraint for x and y
        A_add = [ones(1,n) zeros(1,n) zeros(1,4*m); zeros(1,n) ones(1,n) zeros(1,4*m)];  %2x(2n+2m)
        b_add = zeros(2,1); %2x1
        % b_add = ones(2,1); %2x1
        % b_add = b_add.*[(1+nr)/2*n;(1+nc)/2*n];
    case 'fix_point' % fix the position of some specified piece
        num = length(fix_pos);
        A_add = zeros(num,2*n+4*m);
        ind = (1:num)'+(fix_pos-1)*num;
        A_add(ind) = 1;
        b_add = fix_val;
%     case 'fix_solved' % don't need any constraint in this case
%         A_add = [];
%         b_add = [];
end

Aeq = [A;A_add]; %(2m+x)*(2n+4m);
beq = [b;b_add]; %(2m+x)*1

%% objective function
w = [info(:,3);info(:,3)];
f = [zeros(1,2*n) w' w']';
f = double(f);

%% inequality constraint
A = zeros(4*m,4*m+2*n); %4m*(4m+2n)
A(1:2*m,2*n+1:2*n+2*m) = eye(2*m);
A(2*m+1:4*m,2*n+2*m+1:2*n+4*m) = eye(2*m);
A = -A; b = zeros(4*m,1);

%% make matrices sparse
A = sparse(A);
Aeq = sparse(Aeq);