function [im] = RenderImageWithRotArray_WhiteBG(GI,GR,ap)
%render the puzzle with pieces and rotations. 



            ap2{1} = ap{1}; %initialize to prevent problems... 
            for jj = 1:1:numel(GR)
                if(GR(jj)>0)
                    rv = GR(jj); 
                    rotateCCW = rv-1; 
                    bid = GI(jj); 
                    ap2{bid} = imrotate(ap{bid},90*rotateCCW);
                end
            end

            [im,GraphIds] = renderPiecesFromGraphIDs_WhiteBG(ap2,GI,0);