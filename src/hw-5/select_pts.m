img1 = imread('pics/pic1.jpg');
img2 = imread('pics/pic2.jpg');
% resizing the first figure to adapt it so that we can combine two figures
% together
img1(1876:2500, 1:2500) = zeros((2500 - 1875), 2500);
% combining two imgs together
combined_img = [img1, img2];
% show combined img
figure(1); imshow(combined_img);
hold on;


% select pts
pts_img = getpts;
% size of pts matrix we get
size_pts_img = size(pts_img);
% total points count we wanna use
pts_count = size_pts_img(1);
% all odd points we selected are supposed to be in the first figure
pts_img_1 = [];
for i = 1 : 2 : (pts_count - 1)
   pts_img_1 = [pts_img_1;
       pts_img(i, :)]; 
end
% all even points we selected are supposed to be in the second figure
pts_img_2 = [];
for i = 2 : 2 : pts_count
   pts_img_2 = [pts_img_2;
       (pts_img(i, :) - [2500, 0, 0])];
end

% for testing the coordinate system in MATLAB
% x->right, y->down, ascending, left upper point is the origin
% h = plot(100, 100, 'x', 'Color', 'r', 'MarkerSize', 10);
% set(h, 'linewidth', 3);
% h = plot(1, 100, 'x', 'Color', 'g', 'MarkerSize', 10);
% set(h, 'linewidth', 3);
% h = plot(2600, 1, 'x', 'Color', 'r', 'MarkerSize', 10);
% set(h, 'linewidth', 3);
% h = plot(2500, 100, 'x', 'Color', 'r', 'MarkerSize', 10);
% set(h, 'linewidth', 3);