function boundary = set_boundary(boundary,varargin)

[top,bottom,left,right] = getPrmDflt(varargin,{'top',0,'bottom',0,'left',0,'right',0}, 1);

boundary.top = top;
boundary.bottom = bottom;
boundary.left = left;
boundary.right = right;