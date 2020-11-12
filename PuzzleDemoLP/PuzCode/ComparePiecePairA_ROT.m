function score = ComparePiecePairA_ROT(ap, mode,A,ROTFLAG)
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

onemat = ones(size(ap{1},1),1);   
psize = size(ap{1},1);

oppSide = [3 4 1 2; 4 1 2 3; 1 2 3 4; 2 3 4 1];
mirror = [ 3 4 1 2  16 13 14 15  9 10 11 12 6 7 8 5  ]; %what is the symmetry? %this will cut processing time in half. 

tic

for jj = 1:1:4   % how they fit together    
            fprintf('Fit Number: %d\n',jj)
    for ii = 1:1:N-1

%        if(mod(ii,20)==0)
%            fprintf('Piece Number: %d\n',ii)
%        end
       % p1= ap{ii}; % the puzzle piece
        P1D_mu =    A{jj}.D_mu(ii,:)    ; %1x3
        P1D_cov =   A{jj}.D_cov(:,:,ii)  ;%3x3
        p1S =       A{jj}.pix(ii,:) ;% the pixel values; 
        score(ii,ii,:) = inf; 
        
        
        for RR = 0:1:(ROTFLAG*3) % the number of rotations to do to piece 2. 
        
        
            for kk = ii+1:1:N
                % what is this pieces info? 
                % get the opposite side info
                s = oppSide(RR+1,jj); % this is the opposite side for fitting. 
                % get the difference of the strip between them 

                LayerIndex = jj + RR*4; 
                
            %    p2= ap{kk}; % the puzzle piece
                P2D_mu =    A{s}.D_mu(kk,:);     %1x3
                P2D_cov =   A{s}.D_cov(:,:,kk);  %3x3
                p2S =       A{s}.pixR(kk,:);% the pixel values; 

                % now, compute the score: 

                P12DIF = p1S-p2S; %comp w/ P2D_mu and cov
                P12DIF = reshape(P12DIF', psize,3); 
                P21DIF = -P12DIF; %comp w/ P1D_mu and cov
                %pause


               % D12 =  (P12DIF-(onemat*P2D_mu))*inv(P2D_cov);
                D12 =  (P12DIF-(onemat*P2D_mu))/(P2D_cov);
                D12 = sum(D12 .* (P12DIF-(onemat*P2D_mu)),2);
                D12 = sqrt(D12); 

              %  D21 = (P21DIF-(onemat*P1D_mu))*inv(P1D_cov);
                D21 = (P21DIF-(onemat*P1D_mu))/(P1D_cov);
                D21 = sum(D21.* (P21DIF-(onemat*P1D_mu)),2);
                D21 = sqrt(D21); 

                Dist = sum(D12+D21);           

                if(mode==3)
                    Dist = sum(sum(P12DIF.*P12DIF));  
                end

                score(ii,kk,LayerIndex) = single( Dist);
                score(kk,ii,mirror(LayerIndex)) = single( Dist);
            end
        end
    end
end

score(N,N,:) = inf;

toc