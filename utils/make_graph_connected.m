%
% Written by Vahan Huroyan
%

function [ nn4Mat ] = make_graph_connected(nn4Mat, weights )
%MAKE_GRAPH_CONNECTED Summary of this function goes here
%   Detailed explanation goes here
    numbOfParts = size(nn4Mat, 1);
    for i = 1:numbOfParts
        weights(i, i) = Inf;
    end
    
    [S, c_vals] = graphconncomp(sparse(nn4Mat));
    graph_Vertices = cell(1, S);
    for i = 1:S
        graph_Vertices{i} = find(c_vals == i);
    end

    % Find the largest connected piece
    max_size_index = 0;
    max_group_size = 0;

    for i = 1:S
        if(size(graph_Vertices{i}, 2) > max_group_size)
            max_size_index = i;
            max_group_size = size(graph_Vertices{i}, 2);
        end
    end
    used_patches = graph_Vertices{max_size_index};
    unused_patches = setxor(1:numbOfParts, used_patches);

    while(length(used_patches) < numbOfParts)
        disp(length(used_patches));
        L = weights(unused_patches, used_patches);
    
        [x, y] = find(L == min(min(L)));
        
        disp([length(unused_patches) size(used_patches)]);
        disp([length(x)]);
        disp(min(min(L)));
        
        cur_val = randi(length(x));
        nn4Mat(unused_patches(x(cur_val)), used_patches(y(cur_val))) = 0.001;
        nn4Mat(used_patches(y(cur_val)), unused_patches(x(cur_val))) = 0.001;

%         nn4Mat(unused_patches(x(1)), used_patches(y(1))) = 0.001;
%         nn4Mat(used_patches(y(1)), unused_patches(x(1))) = 0.001;

%         for iter_1 = 1:length(x)
%             nn4Mat(unused_patches(x(iter_1)), used_patches(y(iter_1))) = 0.001;
%             nn4Mat(used_patches(y(iter_1)), unused_patches(x(iter_1))) = 0.001;
%         end

        [S, c_vals] = graphconncomp(sparse(nn4Mat));
        graph_Vertices = cell(1, S);
        for i = 1:S
            graph_Vertices{i} = find(c_vals == i);
        end

        % Find the largest connected piece
        max_size_index = 0;
        max_group_size = 0;

        for i = 1:S
            if(size(graph_Vertices{i}, 2) > max_group_size)
                max_size_index = i;
                max_group_size = size(graph_Vertices{i}, 2);
            end
        end
        used_patches = graph_Vertices{max_size_index};
        unused_patches = setxor(1:numbOfParts, used_patches);
    end

end

