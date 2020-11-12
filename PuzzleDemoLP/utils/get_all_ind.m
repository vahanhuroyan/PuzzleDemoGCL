%% get all the useful indices because pieces are replicated 4 times
function ind = get_all_ind(ind,piece_num)

mask = ind>0;
to_add = (-3:1:3)*piece_num;
ind = bsxfun(@plus,ind,to_add);
mask = repmat(mask,1,length(to_add));
ind = ind(ind > 0 & ind < (4*piece_num+1) & mask);

end