clc;close all; clear all;
% read images
fig_1 = imread('fig_1.jpg');
fig_2 = imread('fig_2.jpg');
% load point coordinates from pre-defined
load('points.mat')
x1 = x1';
x2 = x2';
y1 = y1';
y2 = y2';
% get points from the first figure
%[x1, y1] = getpts(get(imshow('fig_1.jpg'),'Parent'));

% get points from the second figure
%[x2, y2] = getpts(get(imshow('fig_2.jpg'), 'Parent'));

% build matrix for selected points in the first figure
ptsSize1 = size(x1);
ptsCount1 = ptsSize1(1);
ptsSize2 = size(x2);
ptsCount2 = ptsSize2(1);

%X1 = ones(ptsCount1, 3);
%for i = 1:ptsCount1
%    X1(i, 1) = x1(i);
%    X1(i, 2) = y1(i);
%end

% build matrix for selected points in the second figure
%X2 = ones(ptsCount2, 3);
%for i = 1:ptsCount2
%    X2(i, 1) = x2(i);
%    X2(i, 2) = y2(i);
%end

% build A matrix
A = zeros(ptsCount1 * 2, 9);
for i = 1:ptsCount1
    A(2*i - 1, :) = [0 0 0 -x1(i) -y1(i) -1 (y2(i) * x1(i)) (y2(i)*y1(i)) y2(i)];
    A(2*i, :) = [x1(i) y1(i) 1 0 0 0 (-x2(i)*x1(i)) (-x2(i)*y1(i)) (-x2(i))];
end

% singular value decomposition
[U,S,V] = svd(A);
V = V/V(9, 9);
H_col = [V(1, 9), V(2, 9), V(3, 9);
    V(4, 9), V(5, 9), V(6, 9);
    V(7, 9), V(8, 9), V(9, 9);];

transform_col = projective2d(H_col');

% get image reference info for fig_1 and transformed final figure 1
im_ref1 = imref2d(size(fig_1));
[final_1, final_ref1] = imwarp(fig_1, im_ref1, transform_col);

% image reference info for fig_2
im_ref2 = imref2d(size(fig_2));

% composite two images into one using image reference info
[final_composite, final_composite_ref] = imfuse(final_1, final_ref1, fig_2, im_ref2);
image(final_composite);
% write images to file
%imwrite(final_col, 'dlt.jpg');

% useless data
%x1 = [2282.1985645933014; 2484.0526315789471; 2477.3241626794256; 2472.8385167464112; ...
%      2463.8672248803828; 2452.6531100478469; 2452.6531100478469; 2401.0681818181815; ...
%      2300.1411483253587; 2450.4102870813394; 2340.5119617224877; 2439.1961722488036; ...
%      2340.5119617224877; 2748.705741626794];

%x2 = [249.99999999999997; 447.99999999999989; 450.99999999999994; 456.99999999999994; ...
%      465.99999999999994; 465.99999999999994; 465.99999999999994; 414.99999999999994; ...
%      319.00000000000006; 483.99999999999994; 384.99999999999989; 480.99999999999994; ...
%      384.99999999999989; 1264];

%y1 = [1385.4431818181815; 1389.928827751196; 1223.9599282296649; 1111.818779904306; ...
%      900.99342105263133; 856.13696172248785; 822.49461722488013; 788.85227272727252; ...
%      804.55203349282283; 560.08433014354046; 582.51255980861242; 501.77093301435383; ...
%      524.19916267942563; 562.32715311004767];

%y2 = [1400; 1400; 1238; 1127; 926.00000000000011; 887.00000000000011; 851; ...
%      809; 815; 599.00000000000023; 605.00000000000023; 539.00000000000023; ...
%      548.00000000000023; 458.00000000000023];



