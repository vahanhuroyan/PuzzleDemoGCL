%% update SCO based on known outlier matches
function SCO = SCO_update2(SCO,info_del,varargin)

mirror = [3 4 1 2  16 13 14 15  9 10 11 12  6 7 8 5]'; %what is the symmetry? %this will cut processing time in half.

[do_replicate,piece_num] = getPrmDflt(varargin,{'do_replicate',0,'piece_num',0}, 1);

if(do_replicate)  % pieces are replicated     
    info_all = get_all_info(info_del,piece_num);    
else    
    info_all = info_del;    
end


del_num = size(info_all,1);
for i = 1:del_num
    SCO(info_all(i,1),info_all(i,2),info_all(i,4)) = inf;
    SCO(info_all(i,2),info_all(i,1),mirror(info_all(i,4))) = inf;
end
