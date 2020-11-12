function score = ComparePiecePairA_ROT_rui(ap, mode,A,ROTFLAG)
%function score = ComparePiecePairA_ROT(ap, mode,A,ROTFLAG)
%
% Compare two puzzle pieces and get a differnce
% THIS ONE USES ATTRIBUTES A THAT ARE PRE_COMPUTED...
%
% P1 is Puzzle Piece 1
% P2 is Puzzle Piece 2
% edge indicates which edges to compare.
% if we assume that the pieces are orientated correctly,
% then we compare either
% edge:
%   1   top     of P1 w/ bottom of P2
%   2   right   of P1 w/ left of P2
%   3   bottom  of P1 w/ top of P2
%   4   left    of P1 w/ right of P2
%
% There are a few different ways to do the comparison.
% mode:
%  ***************
%  ***************
%  3. SSD
%  ***************
%  ***************
%  7.(actually, anything but 3) The Mahal distance method. (MGC)
%
%
% Do all possible rotations.
% so the output is PxPx16
% where layers 1:4 are no rotations of pieces.
% layers 5:8 are 1 CCW rotation of the second piece
% layers 9:12 are 1 CCW rotation of the 3rd piece
% layers 13:16 are 1 CCW rotation of the 4th piece
%
%
%  score is NxNx4 or NxNx16. Each entry is the compatibilty between those two piece indexes
% at that geometric configuration.
%
%  Andrew Gallagher

if(nargin<4)
    ROTFLAG = 1;
end

N =numel(ap);

if(ROTFLAG)
    score = zeros(N,N,16,'single'); % for rotation related...
else
    score = zeros(N,N,4,'single'); % for non-rotation related...
end


for ii = 1:1:N
    ap{ii} = single(ap{ii});
end

oppSide = [3 4 1 2; 4 1 2 3; 1 2 3 4; 2 3 4 1];

tic

for jj = 1:1:4   % how they fit together
    
    fprintf('Fit Number: %d\n',jj);
    
    for RR = 0:1:(ROTFLAG*3) % the number of rotations to do to piece 2.
        
        Dist = zeros(N,N);
        Dist_new = zeros(N,N);
        
        for ii = 1:N
            
            s = oppSide(RR+1,jj); % this is the opposite side for fitting.
            
            P1D_mu =    A{jj}.D_mu(ii,:)    ; %1x3
            P1D_cov =   A{jj}.D_cov(:,:,ii)  ;%3x3
            p1S  =     A{jj}.pix(ii,:) ;% the pixel values;
            
            score(ii,ii,:) = inf;
            
            % stack pixel values of all the pieces
            pAllR = A{s}.pixR;
            
            diff = bsxfun(@minus,pAllR,p1S);
            diff = permute(reshape(diff,N,[],3),[2 1 3]);
            
            if(mode==3)
                Dist(ii,:) = sum(sum(diff.*diff,1),3);
            else
                diff = reshape(diff,[],3);
                temp = bsxfun(@minus,diff,P1D_mu);
                diff = sqrt(sum((temp/P1D_cov).*temp,2));
                Dist(ii,:)  = sum(reshape(diff,[],N),1)';
            end
            
            
            %% exchange s and jj
            s_new = jj;
            jj_new = s;
            
            P1D_mu =    A{jj_new}.D_mu(ii,:)    ; %1x3
            P1D_cov =   A{jj_new}.D_cov(:,:,ii)  ;%3x3
            p1S  =      A{jj_new}.pix(ii,:) ;% the pixel values;
            
            score(ii,ii,:) = inf;
            
            % stack pixel values of all the pieces
            pAllR = A{s_new}.pixR;
            
            diff = bsxfun(@minus,pAllR,p1S);
            diff = permute(reshape(diff,N,[],3),[2 1 3]);
            
            if(mode==3)
                Dist_new(ii,:) = sum(sum(diff.*diff,1),3);
            else
                diff = reshape(diff,[],3);
                temp = bsxfun(@minus,diff,P1D_mu);
                diff = sqrt(sum((temp/P1D_cov).*temp,2));
                Dist_new(ii,:)  = sum(reshape(diff,[],N),1)';
            end
            
            
        end
        
        if(mode ~= 3)
            Dist = Dist + Dist_new';
        end
        
        Dist(logical(eye(size(Dist)))) = inf;
        
        LayerIndex = jj + RR*4;
        score(:,:,LayerIndex) = single(Dist);
        
    end
end

score(N,N,:) = inf;

toc