single_fig = imread('pics/single.jpg');
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
row_line = cross(C_by_y(12, :), C_by_y(5, :));
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

%h = plot(C(:, 1), C(:, 2), 'x', 'MarkerSize', 15);
%set(h,'linewidth',3);

% LM method
k = [0.05, 0.025];
error_init = err_function(k);
options = optimset('Algorithm', 'levenberg-marquardt', 'Tolfun', 1e-8);
kfinal = lsqnonlin(@err_function, k, [], [], options);

x_0 = img_center(1, 1);
y_0 = img_center(1, 2);
undistort_img = undistortimage(single_fig, 1, x_0, y_0, k(1), k(2), 0, 0, 0, 0);

error_final = err_function(kfinal);
figure, imshow(undistort_img);

% to do this function, make sure:
% 1. pts_count is total points we have
% 2. r contains the radius from image center for all pts_count points
% 3. C contains all coordinates of pts_count points
% 4. crossing_p the crossing point of two lines
% 5. img_center center coordinates for img
function [xy_error] = err_function(k)
    global r;
    global pts_count;
    global img_center;
    global crossing_p;
    global corners;
    x_0 = img_center(1, 1);
    y_0 = img_center(1, 2);
    error = zeros(pts_count, 1);
    xy_error = zeros(pts_count*2, 1);
    for i = 1 : pts_count
       L = 1 + k(1) * r(i) + k(2) * r(i)^2; %+ k(3) * r(i)^3 + k(4) * r(i)^4;
       x_hat = x_0 + L * (corners(i, 1) - x_0);
       y_hat = y_0 + L * (corners(i, 2) - y_0);
       % are we using crossing point or the original coordinates in the img
       x_error = x_hat - crossing_p(i, 1);
       y_error = (y_hat - crossing_p(i, 2));
       xy_error(2*i - 1) = x_error;
       xy_error(2*i) = y_error;
       error(i) = sqrt(x_error^2 + y_error^2);
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

% UNDISTORTIMAGE - Removes lens distortion from an image
%
% Usage:  nim = undistortimage(im, f, ppx, ppy, k1, k2, k3, p1, p2)
%
% Arguments: 
%           im - Image to be corrected.
%            f - Focal length in terms of pixel units 
%                (focal_length_mm/pixel_size_mm)
%     ppx, ppy - Principal point location in pixels.
%   k1, k2, k3 - Radial lens distortion parameters.
%       p1, p2 - Tangential lens distortion parameters.
%
% Returns:  
%          nim - Corrected image.
%
%  It is assumed that radial and tangential distortion parameters are
%  computed/defined with respect to normalised image coordinates corresponding
%  to an image plane 1 unit from the projection centre.  This is why the
%  focal length is required.

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% October   2010  Original version
% November  2010  Bilinear interpolation + corrections
% April     2015  Cleaned up and speeded up via use of interp2
% September 2015  Incorporated k3 + tangential distortion parameters

function nim = undistortimage(im, f, ppx, ppy, k1, k2, k3, k4, p1, p2)
    
    % Strategy: Generate a grid of coordinate values corresponding to an ideal
    % undistorted image.  We then apply the imaging process to these
    % coordinates, including lens distortion, to obtain the actual distorted
    % image locations.  In this process these distorted image coordinates end up
    % being stored in a matrix that is indexed via the original ideal,
    % undistorted coords.  Thus for every undistorted pixel location we can
    % determine the location in the distorted image that we should map the grey
    % value from.

    % Start off generating a grid of ideal values in the undistorted image.
    [rows,cols,chan] = size(im);        
    [xu,yu] = meshgrid(1:cols, 1:rows);
    
    % Convert grid values to normalised values with the origin at the principal
    % point.  Dividing pixel coordinates by the focal length (defined in pixels)
    % gives us normalised coords corresponding to z = 1
    x = (xu-ppx)/f;
    y = (yu-ppy)/f;    

    % Radial lens distortion component
    r2 = sqrt(x.^2+y.^2);                    % Squared normalized radius.
    dr = k1*r2 + k2*r2.^2;% + k3*r2.^3 + k4*r2.^4;  % Distortion scaling factor.
    
    % Tangential distortion component (Beware of different p1,p2
    % orderings used in the literature)
    dtx =    2*p1*x.*y      +  p2*(r2 + 2*x.^2);
    dty = p1*(r2 + 2*y.^2)  +    2*p2*x.*y;    
    
    % Apply the radial and tangential distortion components to x and y
    x = x + dr.*x + dtx;
    y = y + dr.*y + dty;
    
    % Now rescale by f and add the principal point back to get distorted x
    % and y coordinates
    xd = x*f + ppx;
    yd = y*f + ppy;
    
    % Interpolate values from distorted image to their ideal locations
    if ndims(im) == 2   % Greyscale
        nim = interp2(xu,yu,double(im),xd,yd); 
    else % Colour
        nim = zeros(size(im));
        for n = 1:chan
            nim(:,:,n) = interp2(xu,yu,double(im(:,:,n)),xd,yd); 
        end
    end

    if isa(im, 'uint8')      % Cast back to uint8 if needed
        nim = uint8(nim);
    end
end