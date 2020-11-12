%% recover image from ground truth indexing
function im = recover_im_from_gt(nr,nc,ap,PP,ppp)

im = zeros(nr*PP,nc*PP,3);
[~,ind] = sort(ppp);

num = 0;
for j = 1:10
    for i = 1:nr
        num = num+1;
        im((i-1)*PP+1:i*PP,(j-1)*PP+1:j*PP,:)=ap{ind(num)};
    end
end

im = uint8(im);