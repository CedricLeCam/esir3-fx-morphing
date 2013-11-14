function [ output_args ] = vectorwarp( input_args )
%--------------------------------------------------------------------------
% VECTOR BASED WARPING
% -------------------------------------------------------------------------
% Author: Cedric Le Cam
% Date: Ocotber 2013
% -------------------------------------------------------------------------

% select and display start image
[filenameS,pathnameS]=uigetfile('*.jpg', 'select input start image');
imgS = imread(strcat(pathnameS,filenameS));
image(imgS); axis image ; hold on ;
[syS sxS scS] = size(imgS);


% define start feature vectors
[vectS, ptS] = selectVect();


% % select and display goal image
imgG = uint8(zeros(syS,sxS,scS));
image(imgG); axis image ; hold on ;
[syG sxG scG] = size(imgG);

% [filenameG,pathnameG]=uigetfile('*.jpg', 'select input goal image');
% imgG = imread(strcat(pathnameG,filenameG));
% image(imgG); axis image ; hold on ;
% [syG sxG scG] = size(imgG);

% define goal feature vectors
[vectG, ptG] = selectVect();

% computing the warp
% new image 
newimg = uint8(zeros(syS,sxS,scS));

% for all pixel in goal image
for yi=1:syG
    for xi=1:sxG
        color = [0 0 0];
        w = [];
        % for all vectors in goal image
        for k=1:ptG
            %calculer u et v à partir de P'X' et P'Q', notés PXg et PQg
            PXg = [xi-vectG(k,1) yi-vectG(k,2)];
            PQg = [vectG(k,3)-vectG(k,1) vectG(k,4)-vectG(k,2)];
            orthoPQg = [vectG(k,2)-vectG(k,4) vectG(k,3)-vectG(k,1)];
            % d'abord u = prodscal(P'X',P'Q') / norm²(P'Q')
            u(k) = (PXg*PQg') / (PQg*PQg');
            % v = prodscal(P'X',ortho(P'Q')) / norm²(ortho(P'Q'))
            v(k) =(PXg*orthoPQg') / (orthoPQg*orthoPQg') ;
        
        
            % retrouver un (x,y) valable dans l'image de départ
            % calculer coordonnées x et y
            PQ = [vectS(k,3)-vectS(k,1) vectS(k,4)-vectS(k,2)];
            orthoPQ = [vectS(k,2)-vectS(k,4) vectS(k,3)-vectS(k,1)];
            % PX = u.PQ + v.orthoPQ
            PX = u(k)*PQ + v(k)*orthoPQ;
            
            % calcul des candidats
            xs(k) = round(PX(1) + vectS(k,1));
            ys(k) = round(PX(2) + vectS(k,3));
            % application d'un poids au candidat, fonction de la distance
            % au vecteur, donnée par v
            %si coordonnées invalides, poids nul
            if ( xs(k) > 0 && xs(k) < sxS+1 && ys(k) > 0 && ys(k) < syS+1)
                w(k) = weight(v(k));
               % imgS(ys(k),xs(k))
                color(1) = color(1) + w(k)*imgS(ys(k),xs(k),1);
                 color(2) = color(2) + w(k)*imgS(ys(k),xs(k),2);
                  color(3) = color(3) + w(k)*imgS(ys(k),xs(k),3);
%             else
%                 w(k) = 0;
            end
           
%             % version 1 vecteur
%             % si coordonnées valides, garder la couleur
%             if ( xs > 0 && xs < sxS+1 && ys > 0 && ys < syS+1)
%                 
%                 newimg(yi,xi,:) = imgS(ys,xs,:);
%                 
%             end
        end
        color = color / sum(w);
        % application du poids aux candidats, calcul de la couleur
        % d'arrivée
        newimg(yi,xi,:) = color;
    
    end
end

figure;image(newimg); axis image ;
        
end


% sélection des vecteurs sur une image
function [res, pt] = selectVect()
cont = 1 ;
cl = 0 ;
pt = 0 ;
while cont
    [x,y,b] = ginput(1);
    % enter the point
    if cl==0
        % first point
        res(pt+1,:) = [x y 0 0];
    else
        % end point
        res(pt+1,:) = res(pt+1,:)+ [0 0 x y];
        plot([res(pt+1,1) res(pt+1,3)],[res(pt+1,2) res(pt+1,4)],'-');
        plot(res(pt+1,1), res(pt+1,2),'o');
        pt = pt+1;
    end
    cl = mod(cl+1,2);
    if b==3 
        cont = 0 ;
    end
end
% fin de selectVect
end

% fonction de poids
function res = weight(d)
% décroissance inversement proportionnelle au carré
res = 1/(d*d);
% fin weight
end