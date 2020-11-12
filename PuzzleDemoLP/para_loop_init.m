% for parameters brute-force search
% loop_struct: parameters loop structure
% num: total number of combinations

function [loop_struct,num] = para_loop_init(varargin)

loop_struct = [];

% now, fill the quantities in anim according to varargin
if iscell(varargin)
  prmField = varargin(1:2:end); prmVal = varargin(2:2:end);
  for i=1:length(prmField)
    loop_struct = subsasgn(loop_struct,struct('type','.','subs',prmField{i}),prmVal{i});
  end
end

num = 1;
for i=1:length(prmField)
    num = num*length(prmVal{i});
end



