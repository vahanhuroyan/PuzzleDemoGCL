%% get candidate matches and weights for the global ranking

%% Input: SCO,  distance of all the pairwise patches for all configuration
%% info: [id1 id2 w config]

% function info = get_candidate_and_weight(SCO,k,thresh)
%
% LayerNum = size(SCO,3);
% PieceNum = size(SCO,1);
%
% normSCO = get_normSCO(SCO,LayerNum);
% ratio = normSCO;
%
% % minDist = min(SCO,[],2);
% % minDist = repmat(minDist,[1 size(minDist,1) 1]);
% % ratio = SCO./minDist;
%
% % weights = cell(4,1);
% % matches = cell(4,1);
%
% info = [];
%
% for i = 1:LayerNum
%
%     ratio_i = ratio(:,:,i);
%     [ratio_sort,ind] = sort(ratio_i,2);
%
%     ratio_k = ratio_sort(:,1:k);
%     weight = 1./ratio_k;
%     ind = ind(:,1:k);
%
%     mask = ratio_k < thresh;
%     mask = find(mask(:));
%
%     [indx,indy] = ind2sub([PieceNum,k],mask);
%     info = [info;[indx ind(mask) weight(mask) i*ones(length(indx),1)]];
%
% end

function info = get_candidate_and_weight(SCO,k,thresh,method,varargin)

% SCO(SCO==0) = nan;
%% Added on March 12, 2015
%% if the distance is 0 for some cases, just ignore the whole corresponding row and column,

n = size(SCO,1);
LayerNum = size(SCO,3);
t = 0.000000000000001;

normSCO = get_normSCO(SCO,LayerNum);  % the distance ratio(dist/mindist or mindist/second mindist)

% obselete, we do not care noise on distance measure at all
% normSCO = get_normSCO(SCO,LayerNum,varargin);  % the distance ratio(dist/mindist or mindist/second mindist)

% for channel = 1:LayerNum
%     
%     [rr,cc] = find(SCO(:,:,channel)==0);
%     % numzeros = size(rr,1);
%     
%     rtest = bsxfun(@plus,rr ,(0:n-1)*n) + (channel-1)*n*n;
%     ctest = bsxfun(@times,cc,(1:n)) + (channel-1)*n*n;
%     normSCO(rtest(:)) = nan;
%     normSCO(ctest(:)) = nan;
%     
% end

% for i = 1:numzeros    
%     normSCO(rr(i),:,channel(i)) = nan;
%     normSCO(:,cc(i),channel(i)) = nan;    
% end

switch method
    
    case 1  % use ratio as weighting
        
        weight = 1./normSCO;
        weight(isnan(weight)) = -1;
        
        info = [];
        for i = 1:LayerNum
            
            weight_i = weight(:,:,i);
            [weight_sort,ind] = sort(weight_i,2,'descend');
            weight_k = weight_sort(:,1:k);
            ind = ind(:,1:k);
            
            mask = weight_k > 1/thresh;
            mask = find(mask(:));
            [indx,~] = ind2sub([n,k],mask);
%             info = [info;[indx ind(mask) weight_k(mask) i*ones(length(indx),1)]];
            info = [info;[indx ind(mask) min(weight_k(mask),10) i*ones(length(indx),1)]];
            
        end
        
    case 2  % probablistic weighting
        
        info = [];
        lambda = 5;
%                 lambda = 10;
%         lambda = 2;
        
        %         for i = 1:LayerNum
        %             SCO_i = normSCO(:,:,i);
        %             [incSCO_i,ind] = sort(SCO_i,2);
        %             mask = incSCO_i(:,1) ~= 1 & ~isnan(incSCO_i(:,1));
        %             incSCO_k = incSCO_i(mask,1:k);
        %             ind = ind(mask,1:k);
        %             pind = (1:n)'; pind = pind(mask);
        %             indx = repmat(pind,1,k);
        %             weight_k = max(exp(-lambda*incSCO_k.^2),t);
        %             info = [info;[indx(:) ind(:) weight_k(:) i*ones(length(ind(:)),1)]];
        %         end
        
        mat = [1 5 9 13;
            2 6 10 14;
            3 7 11 15;
            4 8 12 16];
        for i = 1:4
            if(LayerNum == 4)
                SCO_i = normSCO(:,:,i);
            else
                SCO_i = normSCO(:,:,mat(i,:));
            end
            SCO_i = reshape(SCO_i,size(SCO_i,1),[]);
            [incSCO_i,ind] = sort(SCO_i,2);
            %             mask = incSCO_i(:,1) ~= 1 & ~isnan(incSCO_i(:,1));
            mask = ~isnan(incSCO_i(:,1));
            incSCO_k = incSCO_i(mask,1:k);
            ind = ind(mask,1:k);
            pind = (1:n)'; pind = pind(mask);
            indx = repmat(pind,1,k);
            weight_k = max(exp(-lambda*incSCO_k.^2),t);           
            
            j = floor((ind-1)/size(SCO_i,1)) + 1;
            ind = mod(ind-1,size(SCO_i,1))+1;
            type = mat(i,j);
            info = [info;[indx(:) ind(:) weight_k(:) type(:)]];
        end
        
    case 3 % inverse distance weighting
        
        info = [];
        weight = get_probInv(SCO,LayerNum,2);
        
        %         normSCO = get_normSCO(SCO,LayerNum);
        %         weight = 1./normSCO;
        %         weight(isnan(weight)) = 0;
        
        for i = 1:LayerNum
            weight_i = weight(:,:,i);
            [weight_i_desc,ind] = sort(weight_i,2,'descend');
            weight_k = weight_i_desc(:,1:k);
            ind = ind(:,1:k);
            pind = (1:n)';
            indx = repmat(pind,1,k);
            info = [info;[indx(:) ind(:) weight_k(:) i*ones(length(ind(:)),1)]];
        end
        
        %         for i = 1:LayerNum
        %
        %             SCO_i = normSCO(:,:,i);
        %             [incSCO_i,ind] = sort(SCO_i,2);
        %             incSCO_k = incSCO_i(:,1:k);
        %             ind = ind(:,1:k);
        %             indx = repmat((1:n)',1,k);
        %
        %             weight_k = max(exp(-lambda*incSCO_k.^2),0.000001);
        %             weight_k = bsxfun(@rdivide,weight_k,sum(weight_k,2));
        %
        %             info = [info;[indx(:) ind(:) weight_k(:) i*ones(length(ind(:)),1)]];
        %
        %         end
        
        %         for i = 1:LayerNum
        %
        %             SCO_i = SCO(:,:,i);
        %             SCO_i = SCO_i./repmat(min(SCO_i,[],2),1,n);
        %             [incSCO_i,ind] = sort(SCO_i,2);
        %             incSCO_k = incSCO_i(:,1:k);
        %             ind = ind(:,1:k);
        %             indx = repmat((1:n)',1,k);
        %
        %             weight_k = exp(-lambda*incSCO_k.^2);
        %             weight_k = bsxfun(@rdivide,weight_k,sum(weight_k,2));
        %
        %             info = [info;[indx(:) ind(:) weight_k(:) i*ones(length(ind(:)),1)]];
        %
        %         end
        
end

del = info(:,3) == single(t);
info(del,:) = [];