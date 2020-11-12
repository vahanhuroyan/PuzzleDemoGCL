%% recover the image from block and pieces
function img = get_im_from_block(G,GR,ap)

pp = size(ap{1},1);
[rr,cc] = size(G);
img = zeros(rr*3,cc*3,3);

for i = 1:rr
    for j = 1:cc
        val = G(i,j);
        if(val > 0)
           img((i-1)*pp+1:i*pp,(j-1)*pp+1:j*pp,:) = imrotate(ap{val},90*(GR(i,j)-1));
        end
    end
end
