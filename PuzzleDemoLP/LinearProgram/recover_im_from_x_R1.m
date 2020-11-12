%% recover image according to optimization result

function [goal,im,real_im] = recover_im_from_x_R1(x,n,nr,nc,ap,PP)

xx = x(1:n);
[val,indx] = sort(xx);
goal = zeros(nr,nc);

for j = 1:nc
    for i = 1:nr        
        num = indx(nr*(j-1)+i);        
        goal(i,j) = num;
        im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=ap{num};
    end
end

%% create the real recovery result
[val_unique,ia] = unique(val);
num = max(val)-min(val)+1;
indx = indx(ia);

st = 0;
count = 1;
total = numel(val_unique);

for j = 1:nc
    for i = 1:nr
        if(st < num)
            st = st + 1;
            ind = indx(count);
            if(val_unique(count) < min(val) + st - 1 + 0.1 && val_unique(count) > min(val) + st - 1 - 0.1)
                real_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=ap{ind};
                if(count < total)
                    count = count + 1;
                end
            else
                real_im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=0;
            end
            if(count > 2 && abs(val_unique(count) - min(val) - round(val_unique(count) - min(val))) > 0.1 && count < total)
                count = count + 1;
            end
            while 1
                if(count > 2 && abs(val_unique(count) - val_unique(count-1)) < 0.01 && count < total)
                    count = count + 1;
                else
                    break;
                end
            end
        end
    end
end