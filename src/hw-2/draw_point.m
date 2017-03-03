load('points.mat')
fig_1 = imread('pics/fig_1.jpg');
fig_2 = imread('pics/fig_2.jpg');

ptsSize1 = size(x1);
ptsCount1 = ptsSize1(1);

figure(1), image(fig_1);
hold on;
h = plot(x1, y1, 'x', 'Color', 'r', 'MarkerSize', 15);
set(h,'linewidth',3);

figure(2), image(fig_2);
hold on;
h = plot(x2, y2, 'x', 'Color', 'green', 'MarkerSize', 15);
set(h,'linewidth',3);




