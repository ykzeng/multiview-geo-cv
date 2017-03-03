clc;close all; clear all;
% read images
fig_1 = imread('pics/fig_1.jpg');
fig_2 = imread('pics/fig_2.jpg');
% load point coordinates from pre-defined
load('points.mat')
x1 = x1';
x2 = x2';
y1 = y1';
y2 = y2';
ptsSize1 = size(x1);
ptsCount1 = ptsSize1(1);
ptsSize2 = size(x2);
ptsCount2 = ptsSize2(1);
% notice we organize all the points here in the vector format (x, y, 1)
global X1;
global X2;
X1 = ones(ptsCount1, 3);
X2 = ones(ptsCount2, 3);

X1(:, 1) = x1(:, 1);
X1(:, 2) = y1(:, 1);

X2(:, 1) = x2(:, 1);
X2(:, 2) = y2(:, 1);
% get points from the first figure
%[x1, y1] = getpts(get(imshow('fig_1.jpg'),'Parent'));

% get points from the second figure
%[x2, y2] = getpts(get(imshow('fig_2.jpg'), 'Parent'));

% this is the pure dlt part
% compute A mat
%global A;
global A;
A_dlt = computeAMat(X1, X2);
% call function to get homography
% final homography from dlt without normalization
H_dlt = dltHomography(A_dlt);
% combine two imgs and show
img_dlt_combined = twoImgHomoCombine(H_dlt', fig_1, fig_2);
figure(1), image(img_dlt_combined);
% write images to file
%imwrite(img_dlt_combined, 'results/pure_dlt.jpg');

% here is the normalized dlt part
% normalizing similarity homography for both images
%global H_norm_1;
H_norm_1 = normSimHomo(X1);
%global H_norm_2;
H_norm_2 = normSimHomo(X2);
% apply normalization on our points
X1_norm = applyHomoPerPt(H_norm_1, X1);
X2_norm = applyHomoPerPt(H_norm_2, X2);
A_norm = computeAMat(X1_norm, X2_norm);
% do DLT to get the normalized DLT homography
H_dlt_norm = dltHomography(A_norm);
% final denormalized dlt homography
H_dlt_denorm = inv(H_norm_2) * H_dlt_norm * H_norm_1;
img_dlt_norm_combined = twoImgHomoCombine(H_dlt_denorm', fig_1, fig_2);
figure(2), image(img_dlt_norm_combined);
%imwrite(img_dlt_norm_combined, 'results/norm_dlt.jpg');

% % now we use DLT homo as the start point to do sampson error minimization
% global variable for jacobian
global E;
% epsilon
global C;
%A = A_dlt_norm;
%se_dlt_norm = sampson_error(H_dlt_denorm);
A = A_dlt;
se_dlt = sampson_error(H_dlt);


% % let's use minimization here
% % cast from mat to vector for adapting sample
% for normalized dlt
[homo_min,resnorm] = lsqnonlin(@sampson_error,H_dlt_norm);
homo_min_denorm = inv(H_norm_2) * homo_min * H_norm_1;
% for pure dlt minimization
%[homo_min,resnorm] = lsqnonlin(@sampson_error,H_dlt);
%homo_min = inv(H_norm_2) * homo_min * H_norm_1;


se_min = sampson_error(homo_min_denorm);

%img_dlt_min = twoImgHomoCombine(homo_min', fig_1, fig_2);
%figure(3), image(img_dlt_min);
%imwrite(img_dlt_min, 'results/dlt_min.jpg');

function img_combined = twoImgHomoCombine(H, fig1, fig2)
    transform = projective2d(H);
    % get image reference info for fig_1 and transformed final figure 1
    im_ref1 = imref2d(size(fig1));
    % new reference of figure 1 after transformation
    [im_trans1, im_trans_ref1] = imwarp(fig1, im_ref1, transform);
    % image reference info for fig_2
    im_ref2 = imref2d(size(fig2));
    % overlap two images
    [img_combined, img_combined_ref] = imfuse(im_trans1, im_trans_ref1, fig2, im_ref2);
end

function A = computeAMat(x1, x2)
    % build matrix for selected points in the first figure
    ptsSize1 = size(x1);
    ptsCount1 = ptsSize1(1);
    ptsSize2 = size(x2);
    ptsCount2 = ptsSize2(1);
    
    A = zeros(ptsCount1 * 2, 9);
    for i = 1:ptsCount1
        A(2*i - 1, :) = [0 0 0 -x1(i, 1) -x1(i, 2) -1 (x2(i, 2) * x1(i, 1)) (x2(i, 2) * x1(i, 2)) x2(i, 2)];
        A(2*i, :) = [x1(i, 1) x1(i, 2) 1 0 0 0 (-x2(i, 1) * x1(i, 1)) (-x2(i, 1) * x1(i, 2)) (-x2(i, 1))];
    end
end
% function that accepts input (x, y) coordinates vector from both image and
% output the homography
function H_col = dltHomography(A)
        
    % build A matrix
    %A = zeros(ptsCount1 * 2, 9);
    %for i = 1:ptsCount1
    %    A(2*i - 1, :) = [0 0 0 -x1(i, 1) -x1(i, 2) -1 (x2(i, 2) * x1(i, 1)) (x2(i, 2) * x1(i, 2)) x2(i, 2)];
    %    A(2*i, :) = [x1(i, 1) x1(i, 2) 1 0 0 0 (-x2(i, 1) * x1(i, 1)) (-x2(i, 1) * x1(i, 2)) (-x2(i, 1))];
    %end

    % singular value decomposition
    [U,S,V] = svd(A);
    V = V/V(9, 9);
    H_col = [V(1, 9), V(2, 9), V(3, 9);
        V(4, 9), V(5, 9), V(6, 9);
        V(7, 9), V(8, 9), V(9, 9);];
end

% function for finding normalizing similarity homography
% accepting x and y vector for a series of points, output the homography
function H_norm =  normSimHomo(X)
    % compute the avg value of both x and y coordinates
    % TODO: whether mean function can be applied to multi row vector like
    % we have here
    avg_x = mean(X(:, 1));
    avg_y = mean(X(:, 2));
    
    % acquire number of points we have
    ptsSize = size(X);
    n = ptsSize(1);
    
    % calculate the sum of distance of every points to the centroid
    dist_sum = 0;
    for i = 1:n
        dist_sum = dist_sum + sqrt((X(i, 1) - avg_x)^2 + (X(i, 2) - avg_y)^2);
    end
    avg_dist = dist_sum / n;
    
    % calculate diagonal element s in similarity homography
    s = sqrt(2) / avg_dist;
    t_x = -s * avg_x;
    t_y = -s * avg_y;
    
    H_norm = [s 0 t_x;
        0 s t_y;
        0 0 1];
end

% function for applying homography point wise
% by default we assume X=(x, y, 1) as a row
function X_new = applyHomoPerPt(H, X)
    X_new = (H * (X'))';
end

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

% this function evaluates the sampson error 

function E_sum = sampson_error( homo_mat)
global A;
global X1;
global X2;
   ptsSize1 = size(X1);
   ptsCount1 = ptsSize1(1);
   ptsSize2 = size(X2);
   ptsCount2 = ptsSize2(1);
   
   n = ptsCount1;
    
   homo = mat_to_vector(homo_mat);
   % residual cost
   e = A * homo';
   J = jacob(homo_mat, X1, X2);
   E_sum = 0;
   for k = 1 : n
    % actual Jacobian
    E = [J(k, 1 : 4)' J(k, 5 : 8)']';
    % actual JJ^T
    B = inv(E * E');
    % epsilon
    C = [ e(2 * k - 1,1)  e(2 * k,1)];
    F = sqrt(C * B * C');
    E_sum = E_sum + F;
   end
end

function h = mat_to_vector(homo)
    h = [homo(1, 1) homo(1, 2) homo(1, 3) homo(2, 1) homo(2, 2) homo(2, 3) homo(3, 1) homo(3, 2) homo(3, 3)];
end

% this function evaluates the jacobian matrix for CH(X).
function J = jacob(homo, X1, X2)

x1_size = (size(X1));
x1_pts = x1_size(1);
x2_size = (size(X2));
x2_pts = x2_size(1);

if(x1_pts ~= x2_pts)
    error('select same amount of points in two figures!');
end

for i = 1 : x1_pts
    a = (-1) * homo(2, 1) + homo(3, 1) * X1(i, 2);
    b = (-1) * homo(2, 2) + homo(3, 2) * X2(i, 2);
    c = 0;
    d = homo(3,1) * X1(i, 1) + homo(3,2) * X1(i, 2) + homo(3,3);
    e = homo(1,1) - homo(3,1) * X1(i, 1);
    f = homo(1,2) - homo(3,2) * X2(i, 1);
    g = (-1) * homo(3,1) * X1(i, 1) - homo(3,2) * X1(i, 2) - homo(3,3);
    gg = 0;
    
    m = [ a b c d];
    n = [ e f g gg ];
    p = [ m n ];
    J(i,:,:) = p';
end

end