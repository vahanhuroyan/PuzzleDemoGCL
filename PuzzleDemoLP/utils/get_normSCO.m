function normSCO = get_normSCO(SCO,LayerNum,varargin)

[add_normalization_noise,snr_para] = getPrmDflt(varargin,{'add_normalization_noise',0,'snr_para',[]}, 1);

normSCO = SCO;
t = 0.000000000000001;

if(LayerNum == 4)
    
    for ii = 1:1:LayerNum %over each possible arrangement.
        
        fprintf('Processing Scores Matrix %d\n',ii);
        [aaa,bbb] = sort(SCO(:,:,ii),2); % sorted over each row.
%         [aaa,bbb] = mink(SCO(:,:,ii),2,2);
        
        rowmins = aaa(:,1:2); %2 smallest over each row.
        rowminloc = bbb(:,1); %location of minimum in each row.
        
        [aaa,bbb] = sort(SCO(:,:,ii)); % sorted over each column.
%         [aaa,bbb] = mink(SCO(:,:,ii),2,1);
        colmins = aaa(1:2,:); %2 smallest over each column.
        colminloc = bbb(1,:); %location of minimum in each column.
        
        for jj = 1:1:size(SCO,1) %over each row.
            
            values = SCO(jj,:,ii);% the values in the row.
            
            n1 = values.*0 + rowmins(jj,1); % the minimum for that row...
            n1(rowminloc(jj)) = rowmins(jj,2); % the second smallest
            
            %each position can also be replaced by the smallest nonsame value in  the column...
            n2 = values.*0 + colmins(1,:); %the minimum value in each column.
            n2(jj==colminloc)= colmins(2,jj==colminloc); % the second smallest
            
            nval = (values+t)./(min([n1;n2])+t);
            normSCO(jj,:,ii) = nval;
            
        end
        
    end
    
else % if rotation is unkown
    
    mat1 = [1 5 9 13; 2 6 10 14; 3 7 11 15; 4 8 12 16];
    mat2 = [1 8 11 14; 2 5 15 12;3 6 9 16; 4 7 10 13; ...
        2 5 15 12;3 6 9 16; 4 7 10 13; 1 8 11 14; ...
        3 6 9 16; 4 7 10 13; 1 8 11 14;2 5 15 12; ...
        4 7 10 13; 1 8 11 14; 2 5 15 12;3 6 9 16];
    
    for ii = 1:1:LayerNum %over each possible arrangement.
        
        fprintf('Processing Scores Matrix %d\n',ii);
        [~,bbb] = sort(SCO(:,:,ii),2); % sorted over each row.
%         [~,bbb] = min(SCO(:,:,ii),2); % sorted over each row.
        rowminloc = bbb(:,1); %location of minimum in each row.
        
        [~,bbb] = sort(SCO(:,:,ii)); % sorted over each column.
%         [~,bbb] = min(SCO(:,:,ii)); % sorted over each column.
        colminloc = bbb(1,:); %location of minimum in each column.
        
        row = floor(mod(ii-1,4)) + 1;
        col = ii;
        
        rowAll = SCO(:,:,mat1(row,:));
        rowAll = min(rowAll,[],3);
        aaa = sort(rowAll,2);
        rowAllmins = aaa(:,1:2);
        colAll = SCO(:,:,mat2(col,:));
        colAll = min(colAll,[],3);
        aaa = sort(colAll);
        colAllmins = aaa(1:2,:);
        
        for jj = 1:1:size(SCO,1) %over each row.
            
            values = SCO(jj,:,ii);% the values in the row.
            
            n1 = values.*0 + rowAllmins(jj,1); %the minimum for 4 rows...
            n1(rowminloc(jj)) = rowAllmins(jj,2); % the second smallest
            
            n2 = values.*0 + colAllmins(1,:); %the minimum value for 4 columns.
            n2(jj==colminloc)= colAllmins(2,jj==colminloc); % the second smallest
            
            nval = (values+t)./(min([n1;n2])+t);
            normSCO(jj,:,ii) = nval;
            
        end
        
    end
    
end

mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half. 

if(add_normalization_noise)
    normSCO_bk = normSCO;
    for dimen = 1:size(normSCO,3)
        normSCO(:,:,dimen) = awgn(normSCO(:,:,dimen),snr_para);
    end    
    %% make sure normSCO is still symmetric
    for dimen = 1:size(normSCO,3)
        tempU = triu(normSCO(:,:,dimen));
        tempL = triu(normSCO(:,:,mirror(dimen)))';
        normSCO(:,:,dimen) = tempU + tempL;
    end    
    normSCO(normSCO<=0) = normSCO_bk(normSCO<=0);    
end