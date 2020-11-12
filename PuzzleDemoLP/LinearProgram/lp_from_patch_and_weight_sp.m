%% %% get the linear program formulation from pairwise match result, sparse formulation
function [f,A,b,Aeq,beq] = lp_from_patch_and_weight_sp(n,info,varargin)

[method,fix_pos,fix_val,prev_label,prev_sol,prev_info] = getPrmDflt(varargin,{'method', 'zero_mean','fix_pos',[], ... 
    'fix_val',[],'prev_label',[],'prev_sol',[],'prev_info',[]}, 1);

%% do some check on info to make sure info(:,4) has only four possible values
if(any(setdiff(unique(info(:,4)),(1:4)')))
   error('info has some configuration beyond 1 to 4, probably are outliers'); 
end

switch method
    case {'zero_mean','fix_point'}
        info = [info;prev_info];
        info = unique(info,'rows');
end

info = double(info);
m = size(info,1); % oberservation

delta_ind = info(:,4) == 2 | info(:,4) == 4;
flip_ind = info(:,4) == 3 | info(:,4) == 2;

%% one part
val = ones(m,1); val(flip_ind) = -1;
b1 = ones(m,1);

%% zero part
delta_ind_zero = ~delta_ind;
b2 = zeros(m,1);

A1 = sparse([1:m 1:m]',[info(:,1)+delta_ind*n;info(:,2)+delta_ind*n],[val;-val],m,2*n);
A2 = sparse([1:m 1:m]',[info(:,1)+delta_ind_zero*n;info(:,2)+delta_ind_zero*n],[val;-val],m,2*n);

A = [A1;A2];
b = [b1;b2];

%% add 2 2mx1 auxilary variable g and h
B = sparse([1:2*m 1:2*m]',[1:2*m 2*m+1:4*m],[-ones(2*m,1) ones(2*m,1)],2*m,4*m);
A = [A B]; % 2m*(2n+4m)

clear A1 A2 B

%% two rows of zeros mean constraints to be added to A
switch method
    case 'zero_mean' % add the zero mean constraint for x and y
        A_add = [ones(1,n) zeros(1,n) zeros(1,4*m); zeros(1,n) ones(1,n) zeros(1,4*m)];  %2x(2n+4m)
        b_add = zeros(2,1); %2x1
        % b_add = ones(2,1); %2x1
        % b_add = b_add.*[(1+nr)/2*n;(1+nc)/2*n];
    case 'fix_point' % fix the position of some specified piece
        num = length(fix_pos);
        A_add = sparse(num,2*n+4*m);
        ind = (1:num)'+(fix_pos-1)*num;
        A_add(ind) = 1;
        b_add = fix_val;
    case 'connected_comp' % move each connected component
        label_list = setdiff(unique(prev_label),-1);
        label_num = length(label_list);        
        A_add = [];
        b_add = [];
        for i = 1:label_num
            pos_x = find(prev_label == label_list(i));
            pos = [pos_x;pos_x+n];
            val = prev_sol(pos);
            num_i = length(pos_x);
            ind1 = [1:2*num_i 1:2*num_i]';
            ind2 = [pos;ones(num_i,1)*2*n+4*m+2*i-1;ones(num_i,1)*2*n+4*m+2*i];
            A_add_i = sparse(ind1,ind2,ones(4*num_i,1),2*num_i,2*n+4*m+2*label_num);
            A_add = [A_add;A_add_i];
            b_add = [b_add;val];
        end
        A = [A sparse(size(A,1),2*label_num)];
    case 'connected_comp+fix_point'
        label_list = setdiff(unique(prev_label),-1);
        label_num = length(label_list);
        
        num = length(fix_pos);
        A_add_fix = sparse(num,2*n+4*m+2*label_num);
        ind = (1:num)'+(fix_pos-1)*num;
        A_add_fix(ind) = 1;
        b_add_fix = fix_val;
        
        A_add = [];
        b_add = [];       
        for i = 1:label_num
            pos_x = find(prev_label == label_list(i));
            pos = [pos_x;pos_x+n];
            val = prev_sol(pos);
            num_i = length(pos_x);
            ind1 = [1:2*num_i 1:2*num_i]';
            ind2 = [pos;ones(num_i,1)*2*n+4*m+2*i-1;ones(num_i,1)*2*n+4*m+2*i];
            A_add_i = sparse(ind1,ind2,ones(4*num_i,1),2*num_i,2*n+4*m+2*label_num);
            A_add = [A_add;A_add_i];
            b_add = [b_add;val];
        end
        
        A_add = [A_add;A_add_fix];
        b_add = [b_add;b_add_fix];        
        A = [A sparse(size(A,1),2*label_num)];
        
%     case 'fix_solved' % don't need any constraint in this case
%         A_add = [];
%         b_add = [];
end

Aeq = [A;A_add]; %(2m+x)*(2n+4m);
beq = [b;b_add]; %(2m+x)*1

clear A b A_add b_add

%% objective function
w = [info(:,3);info(:,3)];
f = [zeros(1,2*n) w' w']';
f = double(f);

%% inequality constraint
% A = sparse(4*m,4*m+2*n); %4m*(4m+2n)
% A(1:2*m,2*n+1:2*n+2*m) = eye(2*m);
% A(2*m+1:4*m,2*n+2*m+1:2*n+4*m) = eye(2*m);

A  = sparse((1:4*m)',(2*n+1:2*n+4*m)',1,4*m,4*m+2*n);
A = -A; b = zeros(4*m,1);

if(strcmp(method,'connected_comp') || strcmp(method,'connected_comp+fix_point'))
   f = [f;zeros(2*label_num,1)];
   A = [A sparse(size(A,1),2*label_num)]; 
end