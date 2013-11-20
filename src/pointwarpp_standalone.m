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
%[filename,pathname]=uigetfile('*.jpg', 'select input image');
%img = imread(strcat(pathname,filename));
close all;
img = imread('tristan.jpg');
image(img); axis image ; hold on ;
[sy sx sc] = size(img);

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


lut = uint8(zeros(sy,sx));
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
            % add displacement
            d = [xi-vect(k,1), yi-vect(k,2)];
            dk = [dx dy]*exp(-2*(d*d')/(2*sigma2));
            dp = dp +dk;
        end
        % end for all vectors    
        xx =clamp(1,xi+round(dp(1)),sx);
        yy = clamp(1,yi+round(dp(2)),sy);
        lut(yy,xx) = 1; % le pixel a une valeur
        % compute new image
        % draw pixel
        newimg(yy,xx,:)=img(yi,xi,:);
    end
end
% % end for all pixel
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERSION INVERSE
% for all pixel
% for yi=1:sy
%     for xi=1:sx
%         % for all displacementvectors
%         dp =[0 0];
%         for k=1:pt
%             % displacement length gives sigma2
%             dx = vect(k,3)-vect(k,1);
%             dy = vect(k,4)-vect(k,2);
%             sigma2 = dx*dx' + dy*dy';
%             % add displacement
%             d = [xi-vect(k,1), yi-vect(k,2)];
%             dk = [dx dy]*exp(-2*(d*d')/(2*sigma2));
%             dp = dp + dk;
%         end
%         % end for all vectors    
%         xx = clamp(1,xi+round(-dp(1)),sx);
%         yy = clamp(1,yi+round(-dp(2)),sy);
%         % compute new image
%         % draw pixel
%         newimg(yi,xi,:)=img(yy,xx,:);
%     end
% end
% end for all pixel



% post processing
for i=1:sy
    for j=1:sx
        if lut(i,j) == 0
            % interpolation du pixel
            ii = i;
            jj = j;
            if i == 1
                ii = i+1;
            end
            if i == sy
                ii = i-1;
            end
            if j == 1
                jj = j+1;
            end
            if j == sx
                jj = j-1;
            end
            
            points = zeros(4,3);
            nb_pts = 0;
            if lut(ii-1,j) == 1
                nb_pts = nb_pts + 1;
                points(nb_pts,:) = newimg(ii-1,j,:);
            end
            if lut(ii,jj+1) == 1
                nb_pts = nb_pts + 1;
                points(nb_pts,:) = newimg(ii,jj+1,:);
            end
            if lut(ii,jj-1) == 1
                nb_pts = nb_pts + 1;
                points(nb_pts,:) = newimg(ii,jj-1,:);
            end
            if lut(ii+1,jj) == 1
                nb_pts = nb_pts + 1;
                points(nb_pts,:) = newimg(ii+1, jj,:);
            end
            
            R = 0;
            G = 0;
            B = 0;
            
            for k=1:nb_pts
               R = R + double(points(k,1));
               G = G + double(points(k,2));
               B = B + double(points(k,3));
            end

            R = R/nb_pts;
            G = G/nb_pts;
            B = B/nb_pts;
            newimg(i,j,:) = [uint8(R), uint8(G), uint8(B)];
            lut(i,j) = 1;
            
        end  
    end
end

figure;image(newimg); axis image ;

end
% function 
function res = clamp(mi,v,ma)
res = min(ma,max(mi,v));
end

