single_fig = imread('pics/two_new.jpg');
single_fig = rgb2gray(single_fig);
figure, imshow(single_fig);
hold on;

% count all points used in the line
pts_vertical = 10;
pts_horizontal = 8;
global pts_count;
pts_count = pts_vertical + pts_horizontal;
img_size = size(single_fig);
% C contains matrix sorted by row 1 (x), we acquired ascending 1st col
global C;
C = get_corners(single_fig);
% C_by_y contains points sorted by row 2 (y), we acquired ascending 2nd col
global C_by_y;
C_by_y = sortrows(C, 2);

% global corner variable for storing all points (from perpendicular lines)
% we wanna use in the error function
global corners;
corners = zeros(pts_count, 3);
% put corner points on both perpendicular lines in corners matrix
corners(1:10, 1:3) = C(1:10, 1:3);
corners(11:18, 1:3) = C_by_y(5:12, 1:3);

global img_center;
img_center = [img_size(1, 2) / 2, img_size(1, 1) / 2, 1];

% calculate the line of first column
col_line = cross(C(1, :), C(10, :));
% calculate the line of first row
row_line = cross(C_by_y(5, :), C_by_y(12, :));
% homogenize both lines
col_line(1, :) = homogenize(col_line);
row_line(1, :) = homogenize(row_line);

% p matrix of points on first col, by calculating cross product
global crossing_p;
crossing_p = ones(pts_count, 3);
% radius vector
global r;
% init radius vector
r = zeros(pts_count, 1);
% compute crossing_p for vertical line, 1st row
for i = 1 : pts_vertical
   % calculate the crossing point between line of first col and line from
   % center of img to the measured corner point
   tmp_line = cross(corners(i, :), img_center);
   tmp_line = homogenize(tmp_line);
   tmp_p = cross(col_line, tmp_line);
   tmp_p = homogenize(tmp_p);
   crossing_p(i, 1:3) = tmp_p;
   
   % calculate radius from each measured point to center of image
   r(i) = sqrt((corners(i, 1) - img_center(1, 1))^2 + (corners(i, 2) - img_center(1, 2))^2);
end

for i = pts_vertical + 1 : pts_count
   % calculate the crossing point between line of first col and line from
   % center of img to the measured corner point
   tmp_line = cross(corners(i, :), img_center);
   tmp_line = homogenize(tmp_line);
   tmp_p = cross(row_line, tmp_line);
   tmp_p = homogenize(tmp_p);
   crossing_p(i, 1:3) = tmp_p;
   
   % calculate radius from each measured point to center of image
   r(i) = sqrt((corners(i, 1) - img_center(1, 1))^2 + (corners(i, 2) - img_center(1, 2))^2);
end

% nonlin method
%k = [0.05, 0.025, 0, 0];
%error_init = err_function(k);
%k = lsqnonlin(@err_function, k);
%error_final = err_function(k);

h = plot(C(:, 1), C(:, 2), 'b.', 'MarkerSize', 8);
set(h,'linewidth',1);

[c_row, c_col] = size(C);
calibrated_corners = zeros(160, 3);
[m, n] = size(single_fig);
x_c = m/2;
y_c = n/2;

for i = 1 : c_row
   x = C(i, 1);
   y = C(i, 2);
   radius = sqrt((x - x_c)^2 + (y - y_c)^2);
   L = 1 + kfinal(1) * radius + kfinal(2) * radius^2;
   calibrated_corners(i, :) = [x_c + L*(x-x_c), y_c + L*(y-y_c), 1];
end

%h = plot(calibrated_corners(:, 1), calibrated_corners(:, 2), 'r.', 'MarkerSize', 8);
%set(h, 'linewidth', 1);

function corners = get_corners(fig)
    tmp_corner = corner(fig);
    corners = sortrows(tmp_corner);
    corner_size = size(corners);
    corner_m = corner_size(1);
    corners(:, 3:3) = ones(corner_m, 1);
end

function vec = homogenize(vec)
    vec(1, 1) = vec(1, 1) / vec(1, 3);
    vec(1, 2) = vec(1, 2) / vec(1, 3);
    vec(1, 3) = 1;
end