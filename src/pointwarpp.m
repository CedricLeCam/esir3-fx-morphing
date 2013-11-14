function [ output_args ] = pointwarpp( input_args )
%--------------------------------------------------------------------------
% POINT BASED WARPING
% -------------------------------------------------------------------------
% Draft version
%
% example of point base warping
%
% displacement field kernel : gaussian function
% hole filling : To Be Done
% -------------------------------------------------------------------------
% Author: Remi Cozot
% Date: June 2012
% -------------------------------------------------------------------------

% select and display image
[filename,pathname]=uigetfile('*.jpg', 'select input image');
img = imread(strcat(pathname,filename));
image(img); axis image ; hold on ;
[sy sx sc] = size(img);     %sc = 3, nb de canaux de couleurs


% warping : point based

% define displacement vectors
cont = 1 ;
cl = 0 ;
pt = 0 ;
while cont
    [x,y,b] = ginput(1);
    % enter the point
    if cl==0
        % first point
        vect(pt+1,:) = [x y 0 0];
    else
        % end point
        vect(pt+1,:) = vect(pt+1,:)+ [0 0 x y];
        plot([vect(pt+1,1) vect(pt+1,3)],[vect(pt+1,2) vect(pt+1,4)],'-');
        plot(vect(pt+1,1), vect(pt+1,2),'o');
        pt = pt+1;
    end
    cl = mod(cl+1,2);
    if b==3 
        cont = 0 ;
    end
end
% computing the warp
% new image 
newimg = uint8(zeros(sy,sx,sc));

% for post processing
changed = uint8(zeros(sy,sx));

% for all pixel
for yi=1:sy
    for xi=1:sx
        % for all displacementvectors
        dp =[0 0];
        for k=1:pt
            % displacement length gives sigma2
            dx = vect(k,3)-vect(k,1);
            dy = vect(k,4)-vect(k,2);
            sigma2 = dx*dx' + dy*dy';
            
            % deplacement inverse
%             dx = vect(k,1)-vect(k,3);
%             dy = vect(k,2)-vect(k,4);
            
            sigma2 = dx*dx' + dy*dy';
            
            % add displacement
            d = [xi-vect(k,1), yi-vect(k,2)];
            dk = [dx dy]*exp(-2*(d*d')/(2*sigma2));
            dp = dp +dk;
        end
    % end for all vectors    
    xx =clamp(1,xi+round(dp(1)),sx);
    yy = clamp(1,yi+round(dp(2)),sy);
    
    % compute new image
    % draw pixel
    newimg(yy,xx,:) = img(yi,xi,:);
    changed(yy,xx) = 1;
    end
end
% end for all pixel

% post processing
for yy = 1:sy
    for xx = 1:sx
        if changed(yy,xx) == 0
            %trouver voisins changés les plus proches et interpolation
            
            
%             %voisin du dessus
%             yup = yy;
%             while yup > 1 || changed(yup,xx) == 0
%                 yup = yup-1 ;
%             end
%             
%             %voisin du dessous
%             ydown = yy;
%             while ydown < sy || changed(ydown,xx) == 0
%                 ydown = ydown+1 ;
%             end
            
            %voisin de gauche
            xleft = xx;
            while xleft > 1 && changed(yy,xleft) == 0
                xleft=xleft-1 ;
            end
            
            %voisin de droite
            xright = xx;
            while xright < sx && changed(yy,xright) == 0
                xright = xright+1;
            end
            
            left = double(newimg(xleft,yy,:));
            right = double(newimg(xright,yy,:));
            
            val = uint8(((xright-xx)/(xright-xleft))*left + ((x-xleft)/(xright-xleft))*right);
            
            newimg(yy,xx,:) = val;
            changed(yy,xx) = 1;
        end
    end
end
        
        

figure;image(newimg); axis image ;

end
% function 
function res = clamp(mi,v,ma)
res = min(ma,max(mi,v));
end

