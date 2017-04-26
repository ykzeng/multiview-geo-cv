close all
clear all
clc

im1=imread('pics/pic1.jpg');
im2=imread('pics/pic2.jpg');
seperate_line_width=25;
seperate_line=zeros(2500,seperate_line_width,3);
seperate_line(:,:,1)=255;
im1(1876:2500, 1:2500) = zeros((2500 - 1875), 2500);
im_com=[im1 seperate_line im2];

figure_handler=figure(1);
image(im_com)
hold on
set(gcf,'Units','centimeters', 'Position',[0 3.5 50 15],'Renderer','painters','color','white');
% all odd points we selected are supposed to be in the first figure
pts_img_1 = [];
% all even points we selected are supposed to be in the second figure
pts_img_2 = [];
if exist('points1.mat','file')>0
    load('points1.mat');
    for j=1:length(x1)
        im1(floor(y1(j))-10:floor(y1(j))+10,floor(x1(j))-10:floor(x1(j))+10,1:2)=255;
        im1(floor(y1(j))-10:floor(y1(j))+10,floor(x1(j))-10:floor(x1(j))+10,3)=0;
        im2(floor(y2(j))-10:floor(y2(j))+10,floor(x2(j))-10:floor(x2(j))+10,1)=0;
        im2(floor(y2(j))-10:floor(y2(j))+10,floor(x2(j))-10:floor(x2(j))+10,2)=250;
        im2(floor(y2(j))-10:floor(y2(j))+10,floor(x2(j))-10:floor(x2(j))+10,3)=150;
        A(2*j-1:2*j,:)=[  0,    0,    0, -x1(j), -y1(j), -1,  y2(j)*x1(j),  y2(j)*y1(j),  y2(j);
                        x1(j), y1(j), 1,   0,      0,     0, -x2(j)*x1(j), -x2(j)*y1(j), -x2(j)];                    
        plot(x1(j),y1(j),'gd','MarkerSize',8);
        plot(x2(j)+(2500+seperate_line_width),y2(j),'ro','MarkerSize',8);
        line([x1(j),x2(j)+(2500+seperate_line_width)],[y1(j),y2(j)],'linewidth',3);
    end
else        
    i=0;
    while i<40
        title( ['selecting the ',num2str(floor(i/2)+1),'-th pair of points'])
        j=floor(i/2)+1;
        if mod(i,2)==0
            h=rectangle('Position',[0.01 0.01 25 18.75]*100,'EdgeColor','g','LineWidth',4);
            [x1(j),y1(j)]=ginput(1);
            if x1(j)<=2500
                plot(x1(j),y1(j),'gd','MarkerSize',8)
                pts_img_1 = [pts_img_1;
                    x1(j), y1(j)]
                i=i+1;
            else
                disp('please select point inside the green box');
            end
        else        
            h=rectangle('Position',[25+seperate_line_width/100 0.01 18.74 24.99]*100,'EdgeColor','g','LineWidth',4);        
            [x2(j),y2(j)]=ginput(1);
            x2(j)=x2(j)-(2500+seperate_line_width);
            if x2(j)>=0
                plot(x2(j)+(2500+seperate_line_width),y2(j),'ro','MarkerSize',8);
                line([x1(j),x2(j)+(2500+seperate_line_width)],[y1(j),y2(j)],'linewidth',3);
                pts_img_2 = [pts_img_2;
                    x2(j), y2(j)]
                i=i+1;
            else
                disp('please select point inside the green box');
            end
        end
    % im_com=[im1 seperate_line im2];
        delete(h);
        %im_com=[im1 seperate_line im2];
        %image(im_com)
        title( ['selecting ',num2str(floor(i/2)+1),'-th pair of points'])
    end
end

%save('points.mat', 'pts_img_1', 'pts_img_2');