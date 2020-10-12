function [ nn4Mat_test ] = initial_nb_construct( nn4Mat, posMat_1, SCO_cr )
%INITIAL_NB_CONSTRUCT Summary of this function goes here
%   Detailed explanation goes here

    a(1, :) = 1:4:16; a(2, :) = 2:4:16; a(3, :) = 3:4:16; a(4, :) = 4:4:16;
    b(1) = 1; b(2) = 1i; b(3) = -1; b(4) = -1i;
    nn4Mat_test = nn4Mat;
    for i = 1:size(nn4Mat, 1)
        x = posMat_1(i, find(nn4Mat(:, i)));
        if(~isempty(x))
            l = find(nn4Mat(:, i));
            for j = 1:(length(x)-1)
                for k = (j+1):length(x)
                    if(x(j) == x(k))
%                         disp(i); disp(l(j)); disp(l(k));
                        y_1 = min(squeeze(SCO_cr(i, l(j), a(b == x(j), :))));
                        y_2 = min(squeeze(SCO_cr(i, l(k), a(b == x(j), :))));
                            if(y_1 < y_2)
                                nn4Mat_test(i, l(k)) = 0;
                                nn4Mat_test(l(k), i) = 0;
                                nn4Mat_test(i, l(j)) = 0.5 * nn4Mat_test(i, l(j));
                                nn4Mat_test(l(j), i) = 0.5 * nn4Mat_test(l(j), i);
                            elseif(y_1 > y_2)
                                nn4Mat_test(i, l(j)) = 0;
                                nn4Mat_test(l(j), i) = 0;
                                nn4Mat_test(i, l(k)) = 0.5 * nn4Mat_test(i, l(k));
                                nn4Mat_test(l(k), i) = 0.5 * nn4Mat_test(l(k), i);
                            else
                                nn4Mat_test(i, l(k)) = 0;
                                nn4Mat_test(l(k), i) = 0;
                                nn4Mat_test(i, l(j)) = 0;
                                nn4Mat_test(l(j), i) = 0;                        
                                disp('--Vahan--');
                            end
                    end
                end
            end
        end
    end
end

