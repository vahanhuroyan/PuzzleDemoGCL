function A = ComputePieceAttributes(P)
%function A = ComputePieceAttributes(P)
%
% Compute the means and covariances on the edges of puzzle pieces. 
%
%
% edge indicates which edges to compare. 
% if we assume that the pieces are orientated correctly, 
% then we compare either
% edge: 
%   1   top     of P1 w/ bottom of P2
%   2   right   of P1 w/ left of P2
%   3   bottom  of P1 w/ top of P2
%   4   left    of P1 w/ right of P2
%
% Andrew Gallagher

    
    
    dummyDiffs = [ 0 0 0 ; 1 1 1; -1 -1 -1; 0 0 1; 0 1 0; 1 0 0 ; -1 0 0 ; 0 -1 0; 0 0 -1]; 

    A = cell(4,1); 
    for edge = [1 2 3 4]

        A{edge}.pixR = zeros(numel(P),size(P{1},1).*3);% assume sq pieces.          
        A{edge}.pix = zeros(numel(P),size(P{1},1).*3);% assume sq pieces.          
        A{edge}.D_mu = zeros(numel(P),3); 
        A{edge}.D_cov =zeros(3,3,numel(P)); 
    end
    for w = 1:1:numel(P)
        P1 = P{w};
        P1 = single(P1);

        % MAYBE PUT IN SOME BIAS POINTS TOO...
        for edge = [1 2 3 4]
            if(edge==1)  %TOP
                S = squeeze(P1(1,:,:)); 
                R = flipud(S); 
                
                P1Dif = squeeze(P1(1,:,:)-P1(2,:,:));
                P1D_mu =  mean(P1Dif);
                %P1D_cov = cov([P1Dif;dummyDiffs ]);  % had some issues with cov. matrixs that had small neg eigenvalues... 
                P1D_cov = cov(double([P1Dif;dummyDiffs ]));
               % [vvv,ddd]=eig(P1D_cov)

            elseif(edge==2)%   2   right   of P1 w/ left of P2
                S = squeeze(P1(:,end,:)); 
                R = flipud(S); 
                

                P1Dif = squeeze(P1(:,end,:)-P1(:,end-1,:));

                P1D_mu =  mean(P1Dif);
                %P1D_cov = cov([P1Dif;dummyDiffs ]);
                P1D_cov = cov(double([P1Dif;dummyDiffs ]));

            elseif(edge==3)% 3   bottom  of P1 w/ top of P2
                R = squeeze(P1(end,:,:));
                S = flipud(R); 
                P1Dif = squeeze(P1(end,:,:)-P1(end-1,:,:));

                P1D_mu =  mean(P1Dif);
 %               P1D_cov = cov([P1Dif;dummyDiffs ]);
                P1D_cov = cov(double([P1Dif;dummyDiffs ]));

            elseif(edge==4)%   4   left    of P1 w/ right of P2
                R = squeeze(P1(:,1,:));
                S = flipud(R); 

                P1Dif = squeeze(P1(:,1,:)-P1(:,2,:));

                P1D_mu =  mean(P1Dif);
%                P1D_cov = cov([P1Dif;dummyDiffs ]);
                P1D_cov = cov(double([P1Dif;dummyDiffs ]));
            end
          %  [w edge]
           S = S(:)';
          %  pause
            A{edge}.pix(w,:) = S;
            A{edge}.pixR(w,:) = R(:)';
            A{edge}.D_mu(w,:) = P1D_mu;
            A{edge}.D_cov(:,:,w) = P1D_cov;
        end
    end


