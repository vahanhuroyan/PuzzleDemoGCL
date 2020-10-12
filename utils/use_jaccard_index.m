function [ nn4Mat_new ] = use_jaccard_index( nn4Mat_test )

% if i and j are neighbors, we want to check the number of neighbors in
% common they have

    nn4Mat_test = nn4Mat_test > 0;
    nn4Mat_new = zeros(size(nn4Mat_test));

    for i = 1:size(nn4Mat_test, 1)
        for j = 1:size(nn4Mat_test, 2)
            if(nn4Mat_test(i, j))
                nn4Mat_cut = nn4Mat_test; nn4Mat_cut(i, j) = 0; nn4Mat_cut(j, i) = 0;
                X = find(nn4Mat_cut(i, :) == 1);
                Y = find(nn4Mat_cut(j, :) == 1);
                XX = X; YY = Y;
                for tt = 1:length(X)
                    XX = unique([XX find(nn4Mat_cut(X(tt), :) == 1)]);
                end
                for tt = 1:length(Y)
                    YY = unique([YY find(nn4Mat_cut(Y(tt), :) == 1)]);
                end

                if(length(intersect(XX, YY)) > 1)
                    nn4Mat_new(i, j) = 1;
                end
            end
        end
    end
%     nn4Mat_old = nn4Mat;
end

