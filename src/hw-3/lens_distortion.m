single_fig = imread('pics/single.jpg');
single_fig = rgb2gray(single_fig);
imshow(single_fig);
hold on;

% count all points used in the line
global pts_count;
pts_count = 10;
img_size = size(single_fig);
% in this img, the first col contains 10 corner points
global C;
C = get_corners(single_fig);
global img_center;
img_center = [img_size(1, 2) / 2, img_size(1, 1) / 2, 1];
% calculate the line of first column
% subject to change
col_line = cross(C(1, :), C(pts_count, :));

col_line(1, :) = homogenize(col_line);

% subject to change
% p matrix of points on first col, by calculating cross product
global crossing_p;
crossing_p = ones(pts_count, 3);
% radius vector
global r;
% subject to change
r = zeros(pts_count, 1);
for i = 1 : pts_count
   % calculate the crossing point between line of first col and line from
   % center of img to the measured corner point
   tmp_line = cross(C(i, :), img_center);
   tmp_line = homogenize(tmp_line);
   tmp_p = cross(col_line, tmp_line);
   tmp_p = homogenize(tmp_p);
   crossing_p(i, 1:3) = tmp_p;
   
   % calculate radius from each measured point to center of image
   r(i) = sqrt((C(i, 1) - img_center(1, 1))^2 + (C(i, 2) - img_center(1, 2))^2);
end

k = [0.5, 0.25, 0.1, 0.1];
error_init = err_function(k);
k = lsqnonlin(@err_function, k);
error_final = err_function(k);

h = plot(C(:, 1), C(:, 2), 'x', 'Color', 'r', 'MarkerSize', 15);
set(h,'linewidth',3);

function error = err_function(k)
    global r;
    global pts_count;
    global img_center;
    global crossing_p;
    global C;
    x_0 = img_center(1, 1);
    y_0 = img_center(1, 2);
    error = 0;
    for i = 1 : pts_count
       L = 1 + k(1) * r(i) + k(2) * r(i)^2 + k(3) * r(i)^3;
       x_hat = x_0 + L * (C(i, 1) - x_0);
       y_hat = y_0 + L * (C(i, 2) - y_0);
       % are we using crossing point or the original coordinates in the img
       error = error + sqrt((x_hat - crossing_p(i, 1))^2 + (y_hat - crossing_p(i, 2))^2);
    end
end

function vec = homogenize(vec)
    vec(1, 1) = vec(1, 1) / vec(1, 3);
    vec(1, 2) = vec(1, 2) / vec(1, 3);
    vec(1, 3) = 1;
end

function corners = get_corners(fig)
    tmp_corner = corner(fig);
    corners = sortrows(tmp_corner);
    corner_size = size(corners);
    corner_m = corner_size(1);
    corners(:, 3:3) = ones(corner_m, 1);
end