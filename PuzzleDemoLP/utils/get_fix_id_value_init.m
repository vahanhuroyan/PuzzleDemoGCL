%% get fixed id and value for initialization
%% get the best possible match and fix the position of one of the piece of this match

function [fix_id,fix_value] = get_fix_id_value_init(info,nr,nc,do_replicate)

fix_id = find_best_match(info,nr*nc,do_replicate);
fix_value = [-100000;-100000];
if(do_replicate)
    prob_id = fix_id+(-3:1:3)*nr*nc;
    mask = (prob_id > 0) & (prob_id < 4*nr*nc + 1);
    prob_id = prob_id(mask);
    fix_id = prob_id;
    fix_id = [fix_id;fix_id+nr*nc*4];
    add_value = [100000 100000 -100000;
        100000 -100000  100000];
    fix_value = [fix_value add_value];
    fix_id = fix_id(:);
    fix_value = fix_value(:);
else
    fix_id = [fix_id;fix_id+nr*nc];
end