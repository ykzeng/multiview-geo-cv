clear all; close all; clc;
single_fig = imread('pics/single.jpg');
single_fig = rgb2gray(single_fig);
figure(1); imshow(single_fig);
hold on;

% get all corner points in the single checker board figure
raw_corners = get_corners(single_fig);

% draw all corner points on the figure
% h = plot(raw_corners(:, 1), raw_corners(:, 2), 'x', 'Color', 'r', 'MarkerSize', 15);
% set(h,'linewidth',3);

% corners sorted by x, 1st row
s_corners_x = sortrows(raw_corners, 1);
s_corners_y = sortrows(raw_corners, 2);

% change this for new image
% get desired horizotal points and vertical points
vPts = s_corners_x(1:10, :);
hPts = s_corners_y(5:12, :);
% show all corner points on img
%h = plot(hPts(:, 1), hPts(:, 2), 'x', 'Color', 'r', 'MarkerSize', 15);
%set(h,'linewidth',3);
%h = plot(vPts(:, 1), vPts(:, 2), 'x', 'Color', 'b', 'MarkerSize', 15);
%set(h,'linewidth',3);

% change this for new image
% compute count of vertical and horizontal points
global vPtsCount hPtsCount;
vPtsCount = 10 - 1 + 1;
hPtsCount = 12 - 5 + 1;

% compute horizontal line and vertical line
% use the first point and the last point
vLine = cross(vPts(1, :), vPts(vPtsCount, :));
hLine = cross(hPts(1, :), hPts(hPtsCount, :));
% normalize
vLine = [vLine(1)/vLine(3), vLine(2)/vLine(3), 1];
hLine = [hLine(1)/hLine(3), hLine(2)/hLine(3), 1];

% test if the line is correct
%tmp = vPts(10, :) * (vLine');
%tmp = hPts(1, :) * (hLine');
global x_c y_c;
[y_c, x_c] = size(single_fig);
x_c = x_c / 2;
y_c = y_c / 2;
img_center = [x_c, y_c, 1];

center2V = [];
center2H = [];
% compute lines from center to points on vertical or horizontal line
for i = 1 : vPtsCount
   tmpLine = cross(img_center, vPts(i, :));
   % draw line between img center and vertical points
   %line([img_center(1), vPts(i, 1)], [img_center(2), vPts(i, 2)]);
   % normalize
   tmpLine = [tmpLine(1)/tmpLine(3), tmpLine(2)/tmpLine(3), 1];
   center2V = [center2V; tmpLine];
end
for i = 1 : hPtsCount
   tmpLine = cross(img_center, hPts(i, :));
   % draw line between img center and horizontal points
   %line([img_center(1), hPts(i, 1)], [img_center(2), hPts(i, 2)]);
   % normalie
   tmpLine = [tmpLine(1)/tmpLine(3), tmpLine(2)/tmpLine(3), 1];
   center2H = [center2H; tmpLine];
end
% compute interceptions
v_inter = [];
h_inter = [];
for i = 1 : vPtsCount
   tmpPt = cross(center2V(i, :), vLine(1, :));
   tmpPt = [tmpPt(1)/tmpPt(3), tmpPt(2)/tmpPt(3), 1];
   v_inter = [v_inter; tmpPt];
end
for i = 1 : hPtsCount
   tmpPt = cross(center2H(i, :), hLine(1, :));
   tmpPt = [tmpPt(1)/tmpPt(3), tmpPt(2)/tmpPt(3), 1];
   h_inter = [h_inter; tmpPt];
end
% construct matrix containing all measured point x-y coordinates, from 
% vertical to horizontal
global measuredPts;
measuredPts = [];
% geometric distance from measurements to img center
global dist2center;
dist2center = [];
for i = 1 : vPtsCount
    measuredPts = [measuredPts; vPts(i, 1:2)];
    tmpDist = sqrt((vPts(i, 1) - x_c)^2 + (vPts(i, 2) - y_c)^2);
    dist2center = [dist2center; tmpDist];
end
for i = 1 : hPtsCount
    measuredPts = [measuredPts; hPts(i, 1:2)];
    tmpDist = sqrt((hPts(i, 1) - x_c)^2 + (hPts(i, 2) - y_c)^2);
    dist2center = [dist2center; tmpDist];
end
% construct matrix containing all interception correspondence
global interPts;
interPts = [];
for i = 1 : vPtsCount
    interPts = [interPts; v_inter(i, 1:2)];
end
for i = 1 : hPtsCount
    interPts = [interPts; h_inter(i, 1:2)];
end
global err;
err = 0;
k = [0.05, 0.025, 0.005];
dev_init = err_func(k);

options = optimset('Algorithm', 'levenberg-marquardt', 'Tolfun', 1e-8);
kfinal = lsqnonlin(@err_func, k, [], [], options);
dev_final = err_func(kfinal);

% lens distortion correction
undistorted_img = undistortimage(single_fig, 1, x_c, y_c, kfinal(1), kfinal(2), kfinal(3), 0, 0, 0);
figure(2); imshow(undistorted_img); hold on;

kfinal = [kfinal 0];
undisPts = undistortPts(measuredPts, x_c, y_c, kfinal);