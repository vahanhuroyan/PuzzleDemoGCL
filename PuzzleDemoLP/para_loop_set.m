function para = para_loop_set(para,loop_num,loop_struct)

if(isempty(loop_struct))
   return
end

loop_names = fieldnames(loop_struct);
num = size(loop_names,1);

cache = zeros(1,num);
ind = zeros(1,num);

for i = num:-1:1
    loop_name = loop_names{i};
    val = loop_struct.(loop_name);
    cache(i) = size(val,2);  % get number of possible values    
end

cache = cumprod(cache(end:-1:1));  %
% cache = cache(end:-1:1);

loop_num = loop_num - 1;

for i = 1:num-1
   
    loop_name = loop_names{i};
    val = loop_struct.(loop_name);    
    ind(i) = floor(loop_num/cache(num-i));    
    loop_num = loop_num - ind(i)*cache(num-i);    
    para.(loop_name) = val(ind(i)+1);
    
end

loop_name = loop_names{num};
val = loop_struct.(loop_name);
ind(num) = loop_num;
para.(loop_name) = val(ind(num)+1);

for i = 1:num
    
   loop_name = loop_names{i};
   fprintf('%s = %d\n',loop_name,para.(loop_name));
    
end
