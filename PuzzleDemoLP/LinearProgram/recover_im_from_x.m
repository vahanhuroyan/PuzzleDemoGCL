%% recover image according to the optimization result, keep all connected component
function [real_sol,real_goal,real_rot] = recover_im_from_x(x,n,nr,nc,ap,PP,varargin)

[rot,rlabel,info_ind,bit,save_result,save_folder,save_name,plot_res, ...
    unique_pos,prev_sol,info_new] = ... 
    getPrmDflt( varargin,{'rot',[],'rlabel',[],'info_ind',[],'bit', 8, ... 
    'save_result',0,'save_folder',[],'save_name',[],'plot_res',0, ...
    'unique_pos',1,'prev_sol',[],'info_new',[]},1);

%% Fix the rotation first
if(~isempty(rot))
    for i = 1:n
       if(rlabel(i) ~= -1)
          ap{i} = imrotate(ap{i},-90*(rot(i)-1));        
       end
    end
else
    rot = ones(n,1); invmap = 1:n;
end

mask = zeros(n,1);
if(~isempty(info_ind))
    mask(info_ind) = 1;
end

xx = x(1:n);
yy = x(n+1:2*n);

%% trivial recovery

% [valx,indx] = sort(xx);
% [valy,indy] = sort(yy);
% [valz,indz] = sort(xx+yy);
% 
% goal = zeros(nr,nc);
% for i = 1:nr
%    % extract the value row by row
%     id = indx(nc*(i-1)+1:nc*i);
%     [~,cind] = sort(yy(id));
%     goal(i,:) = id(cind);
% end
% 
% im = zeros(nr*PP,nc*PP,3);
% 
% for i = 1:nr   
%    for j = 1:nc
%        num = goal(i,j);
%        im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=ap{num};
%    end
% end

%% 

% mask_x = xx > -2*nr & xx < 2*nr;
% mask_y = yy > -2*nc & yy < 2*nc;
% mask_x = mask_x & mask;
% mask_y = mask_y & mask;

mask_x = logical(mask);
mask_y = logical(mask);

minx = min(xx(mask_x));
miny = min(yy(mask_y));
maxx = max(xx(mask_x));
maxy = max(yy(mask_y));

nr_sol = round(maxx - minx + 1);
nc_sol = round(maxy - miny + 1);

real_goal = zeros(nr_sol,nc_sol);
real_rot = zeros(nr_sol,nc_sol);

if(unique_pos)
    for j = 1:nc_sol
        for i = 1:nr_sol
            valx = minx + i -1;
            valy = miny + j -1;
            id = (xx > valx-0.1 & xx < valx+0.1 & yy > valy-0.1 & yy < valy+0.1);
            if(sum(id) == 1)
                pij = find(id);
                real_goal(i,j) = pij;
                if(rlabel(pij) ~= -1)                    
                    real_rot(i,j) = rot(pij);
                end
            else
                real_goal(i,j) = -sum(id);
            end
        end
    end
else %% add useful pieces on top of previous solution, start adding on top of the boundary of previous solution
    real_goal = do_fill_from_info(info_new,prev_sol,x(1:2*n));
end

%% get the biggest component
% mask = real_goal > 0;
% [L, num] = bwlabel(mask, 4);
% lab_count = zeros(num,1);
% for i = 1:num
%     lab_count(i) = sum(sum(L==i));
% end
% [~,ind] = max(lab_count);
% real_goal(L ~= ind) = 0;

%% crop unused ones
% col_mask = sum(real_goal < 0 | real_goal == 0) == size(real_goal,1);
% real_goal = real_goal(:,~col_mask);
% real_rot = real_rot(:,~col_mask);
% 
% row_mask = sum(real_goal < 0 | real_goal == 0,2) == size(real_goal,2);
% real_goal = real_goal(~row_mask,:);
% real_rot = real_rot(~row_mask,:);

[real_goal,del_r,del_c] = my_crop(real_goal);
real_rot(del_r,:) = [];
real_rot(:,del_c) = [];

%% recover the image
[nr_sol,nc_sol] = size(real_goal);
real_sol = zeros(nr_sol*PP,nc_sol*PP,3);
for j = 1:nc_sol
    for i = 1:nr_sol
        ind = real_goal(i,j);
        if(ind > 0)
            real_sol((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=ap{ind};        
        end
    end
end

if(plot_res)
    figure(1)
    switch bit        
        case 8            
%             subplot(1,2,1);
%             imshow(uint8(im));
%             subplot(1,2,2);
            real_sol = uint8(real_sol);
            imshow(real_sol,'Border','tight');            
        case 16            
%             subplot(1,2,1);
%             imshow(uint16(im));
%             subplot(1,2,2);
            real_sol = uint16(real_sol);
            imshow(real_sol,'Border','tight');
    end    
end

if(save_result)
    if(exist(save_folder,'dir') == 0)          % if the folder doesn't exsit
        mkdir(save_folder);
    end
    imwrite(real_sol,fullfile(save_folder,save_name));    
end