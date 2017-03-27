clear all; close all; clc;
two_img = imread('pics/two_new.jpg');
two_img = rgb2gray(two_img);
figure(1); imshow(two_img);
hold on;

% get all corner points in the single checker board figure
raw_corners = get_corners(two_img);

% draw all corner points on the figure
%h = plot(raw_corners(:, 1), raw_corners(:, 2), 'x', 'Color', 'r', 'MarkerSize', 15);
%set(h,'linewidth',3);

% corners sorted by x, 1st row
% sort by first coordinate (x) we get points by vertical lines
rawVCorners = sortrows(raw_corners, 1);
%hCorners = sortrows(raw_corners, 2);

% count of all corner pts on the image
corners_size = size(raw_corners);
ptsCount = corners_size(1);
% count of pts per vertical/horizontal line
vLinesCount = 10;
hLinesCount = 16;

sortedVCorners = [];
% sort vertical points top-down (ascending y)
for i = 1 : hLinesCount
    sIndex = (i - 1) * vLinesCount + 1;
    endIndex = i * vLinesCount;
    tmpVPtsSet = rawVCorners(sIndex:endIndex, :);
    tmpVPtsSet = sortrows(tmpVPtsSet, 2);
    sortedVCorners = [sortedVCorners; tmpVPtsSet];
end
% get the first two row (2d coordinate for img frame)
imgPts = sortedVCorners(:, 1:3);

% test the sequence of rawVCorners(partially sorted) points
% for i = 1 : ptsCount
%     h = plot(rawVCorners(i, 1), rawVCorners(i, 2), 'x', 'Color', 'r', 'MarkerSize', 6);
%     set(h, 'linewidth', 3);
% end
% test the sequence of sortedVCorners(totally sorted) points
for i = 1 : ptsCount    
    h = plot(sortedVCorners(i, 1), sortedVCorners(i, 2), 'x', 'Color', 'r', 'MarkerSize', 6);
    set(h, 'linewidth', 3);
end

% compute the world coordinate based on actual measurements
xzPts = [];
yzPts = [];

% processing xz plane
% first determine the coordinate of a reference point
leftTop1 = [192.5, 0, 220.5];
% based on the same sequence of our corner seeking function, determine the
% corresponding world coordinates of those corners
for i = 1 : (hLinesCount / 2)
    tmpX = leftTop1(1) - (i - 1) * 24.5;
    for j = 1 : (vLinesCount)
        tmpZ = leftTop1(3) - (j - 1) * 24.5;
        xzPts = [xzPts; [tmpX, 0, tmpZ, 1]];
    end
end

% processing yz plane
leftTop2 = [0, 23.5, 220.5];
for i = 1 : (hLinesCount / 2)
    tmpY = leftTop2(2) + (i - 1) * 24.5;
    for j = 1 : (vLinesCount)
        tmpZ = leftTop1(3) - (j - 1) * 24.5;
        yzPts = [yzPts; [0, tmpY, tmpZ, 1]];
    end
end
% integrate xz and yz plane points into the same mat
worldPts = [xzPts; yzPts];

% do normalization for both world frame and image frame
[worldHomo, worldNorm] = normalize(worldPts, 3);
[imgHomo, imgNorm] = normalize(imgPts, 2);

% do DLT
% compute A matrix, ptsCount*2 rows and 3*4 cols
A = zeros(ptsCount * 2, 12);
for i = 1 : ptsCount
   A(2*i-1, :) = [zeros(1, 4) -worldNorm(i, :) imgNorm(i, 2)*worldNorm(i, :)];
   A(2*i, :) = [worldNorm(i, :) zeros(1, 4) -imgNorm(i, 1)*worldNorm(i, :)];
end
% do singular value decomposition
[U, D, V] = svd(A);
% basically aliase V as p
p = V(:, end);

% compute errors before applying LM minimization
tmpP = [p(1) p(2) p(3) p(4); p(5) p(6) p(7) p(8); p(9) p(10) p(11) p(12)];
tmpP = imgHomo\(tmpP * worldHomo);
lastSumSqrt = sqrt(sum(tmpP(3,1:3).^2));
tmpP = tmpP / lastSumSqrt;
xcenter = worldPts * tmpP';
xnew = xcenter(:,:) ./ xcenter(:,3);
error_init = sum(sum((imgPts - xnew).^2))/320;
fprintf('Error before LM is: %d\n',error_init);

% LM
% options for using LM
opt = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
[q,res] = lsqcurvefit(@geoDist,p,worldNorm,imgNorm,[],[],opt); % Refined parameter

P = vec2mat(q,4);
P = imgHomo \ P * worldHomo;
lastSumSqrt = sqrt(sum(P(3,1:3).^2));
P = P / lastSumSqrt;
% check error after LM
xcupdate = worldPts * P';
xnew = xcupdate(:,:)./xcupdate(:,3);

error_lm = sum(sum((imgPts - xnew).^2))/320;
fprintf('Errors after LM: %d\n', error_lm);

% final result
[Q,R] = qr(P(1:3,1:3)^(-1));
K = R^(-1);
K = K / K(3,3);
C = -P(1:3,1:3)\P(:,4);

% for testing the sequence of world frame point generation
% figure(2);
% for i = 1 : (ptsCount / 2)
%      scatter3(xzPts(i, 1), xzPts(i, 2), xzPts(i, 3));
%      hold on;
% end
% for i = 1 : (ptsCount / 2)
%      scatter3(yzPts(i, 1), yzPts(i, 2), yzPts(i, 3));
%      hold on;
% end
% scatter3(xzPts(:, 1), xzPts(:, 2), xzPts(:, 3));
% hold on;
%scatter3(yzPts(:, 1), yzPts(:, 2), yzPts(:, 3));
%hold on;

