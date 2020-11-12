spath = '/home/cvfish/Work/code/bitbucket/JigsawPuzzle/PuzzleDemoLP/Illustration/4/png/kk_1_iter_5_thresh_0.8_method_2_match_0_0_0/im_1/rigid/Illustration';


% %% This generates the set of all possible matches U
% for o = 1:4
%     for i = 1:4
%         for j = 1:4
%             if(j == i)
%                 continue;
%             end
%             if(o==1)
%                 am = [ap{j};ap{i}];
%                 piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%                 imwrite(am, [spath, '/', piece_name]);
%             end
%             if(o==2)
%                 am = [ap{i} ap{j}];
%                 piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%                 imwrite(am, [spath, '/', piece_name]);
%             end
%             if(o==3)
%                 am = [ap{i}; ap{j}];
%                 piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%                 imwrite(am, [spath, '/', piece_name]);
%             end
%             if(o==4)
%                 am = [ap{j} ap{i}];
%                 piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%                 imwrite(am, [spath, '/', piece_name]);
%             end
%         end
%     end
% end


%% This generates the set of active matches A, matches keeped
% num = size(info,1);
% for iter = 1:num
%     
%     i = info(iter,1);
%     j = info(iter,2);
%     o = info(iter,4);
%     
%     if(j == i)
%         continue;
%     end
%     if(o==1)
%         am = [ap{j};ap{i}];
%         piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%         imwrite(am, [spath, '/', piece_name]);
%     end
%     if(o==2)
%         am = [ap{i} ap{j}];
%         piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%         imwrite(am, [spath, '/', piece_name]);
%     end
%     if(o==3)
%         am = [ap{i}; ap{j}];
%         piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%         imwrite(am, [spath, '/', piece_name]);
%     end
%     if(o==4)
%         am = [ap{j} ap{i}];
%         piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
%         imwrite(am, [spath, '/', piece_name]);
%     end
% end


%% This generates the set of active matches R
info_del = info_input(info_input(:,3) < 0.8,:);
num = size(info_del,1);
for iter = 1:num
    
    i = info_del(iter,1);
    j = info_del(iter,2);
    o = info_del(iter,4);
    
    if(j == i)
        continue;
    end
    if(o==1)
        am = [ap{j};ap{i}];
        piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
        imwrite(am, [spath, '/', piece_name]);
    end
    if(o==2)
        am = [ap{i} ap{j}];
        piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
        imwrite(am, [spath, '/', piece_name]);
    end
    if(o==3)
        am = [ap{i}; ap{j}];
        piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
        imwrite(am, [spath, '/', piece_name]);
    end
    if(o==4)
        am = [ap{j} ap{i}];
        piece_name = sprintf('config_%d_p%dtp%d.png',o,i,j);
        imwrite(am, [spath, '/', piece_name]);
    end
end