%% get inverse distance weighting

function weight = get_probInv(SCO,LayerNum,k)

t = 10000000000000;

invSCO = 1./SCO;
invSCO(invSCO==inf) = t;

weight = invSCO;

nr = size(SCO,1);
nc = size(SCO,2);

if(LayerNum == 4) 

    for i = 1:LayerNum
        
        invSCO_i = invSCO(:,:,i);
        
        %% sum over all
%         invSCO_i = invSCO_i./(bsxfun(@plus,sum(invSCO_i,2),sum(invSCO_i,1))-invSCO_i);
        
        %% sum over top k best        
        invSCO_i_rsort = sort(invSCO_i,2,'descend');
        invSCO_i_csort = sort(invSCO_i,1,'descend');
        invSCO_i_rsort = sum(invSCO_i_rsort(:,1:k),2);
        invSCO_i_csort = sum(invSCO_i_csort(1:k,:),1);        
        invSCO_i = invSCO_i./(bsxfun(@plus,invSCO_i_rsort,invSCO_i_csort)-invSCO_i);        
        weight(:,:,i) = invSCO_i;
        
    end
    
else % if rotation is unknown
    
    mat1 = [1 5 9 13; 2 6 10 14; 3 7 11 15; 4 8 12 16];
    mat2 = [1 8 11 14; 2 5 15 12;3 6 9 16; 4 7 10 13; ...
        2 5 15 12;3 6 9 16; 4 7 10 13; 1 8 11 14; ...
        3 6 9 16; 4 7 10 13; 1 8 11 14;2 5 15 12; ...
        4 7 10 13; 1 8 11 14; 2 5 15 12;3 6 9 16];
    map = [1 2 3 4 2 3 4 1 3 4 1 2 4 1 2 3];
    
    invSCO_ar = zeros(nr,nc,4);
    invSCO_ac = zeros(nr,nc,4);
    
    for i = 1:4
        
        %% sum over all
%         invSCO_ai = sum(invSCO(:,:,mat1(i,:),3));
%         invSCO_ar(:,:,i) = repmat(sum(invSCO_ai,2),1,nc);        
%         invSCO_ai = sum(invSCO(:,:,mat2(i,:),3));
%         invSCO_ac(:,:,i) = repmat(sum(invSCO_ai,1),nr,1);  
        
        %% sum over top k best
        invSCO_ai = reshape(invSCO(:,:,mat1(i,:)),nr,nc*4);
        invSCO_ai_rsort = sort(invSCO_ai,2,'descend');
        invSCO_ai_rsort = sum(invSCO_ai_rsort(:,1:k),2);
        invSCO_ar(:,:,i) = repmat(invSCO_ai_rsort,1,nc);
        
        invSCO_ai = reshape(permute(invSCO(:,:,mat2(i,:)),[1 3 2]),nr*4,nc);
        invSCO_ai_rsort = sort(invSCO_ai,1,'descend');
        invSCO_ai_rsort = sum(invSCO_ai_rsort(1:k,:),1);
        invSCO_ac(:,:,i) = repmat(invSCO_ai_rsort,nr,1);
        
    end
    
    for i = 1:LayerNum    
         fprintf('Processing Scores Matrix %d\n',ii);        
         
         invSCO_i = invSCO(:,:,i);
         r = floor(mod(i-1,4)) + 1;
         c = map(i);
         
         invSCO_r = invSCO_ar(:,:,r);
         invSCO_c = invSCO_ar(:,:,c);         
         invSCO_i = invSCO_i./(bsxfun(@plus,invSCO_r,invSCO_c)-invSCO_i);
         weight(:,:,i) = invSCO_i;
         
    end
    
end

% weight = weight*nr*2*LayerNum/4;