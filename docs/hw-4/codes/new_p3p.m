clear all; close all; clc;
img = imread('pics/p3p.jpg');
img = rgb2gray(img);
figure(1); imshow(img);
hold on;

% get all corner points in the single checker board figure
raw_corners = get_corners(img);

% corners sorted by x, 1st row
% sort by first coordinate (x) we get points by vertical lines
rawVCorners = sortrows(raw_corners, 1);

%h = plot(rawVCorners(:, 1), rawVCorners(:, 2), 'x', 'Color', 'r', 'MarkerSize', 15);
%set(h,'linewidth',3);

% count of all corner pts on the image
corners_size = size(rawVCorners);
ptsCount = corners_size(1);

vLinesCount = 8;
hLinesCount = 10;

sortedVCorners = [];
% do sorting for each vertical line
for i = 1 : vLinesCount
    sIndex = ( i - 1) * hLinesCount + 1;
    endIndex = i * hLinesCount ;
    tmpVPtsSet = rawVCorners ( sIndex : endIndex , :) ;
    tmpVPtsSet = sortrows ( tmpVPtsSet , 2) ;
    sortedVCorners = [ sortedVCorners ; tmpVPtsSet ];
end

world = [];
for i = 1 : vLinesCount
    for j = 1 : hLinesCount
       % TODO
       world = [world;
           (i - 1) * 30 (270 - 30 * (j - 1)) 0];
    end
end
% test the sequence of pts
for i = 1 : ptsCount
    h = plot(sortedVCorners(i, 1), sortedVCorners(i, 2), 'x', 'Color', 'r', 'MarkerSize', 6);
    set(h, 'linewidth', 3);
end

%c_x = 156.4369276062062;
global c_x c_y f_x f_y; 
c_x = 239.43;
c_y = 319.7357482216087;
f_x = 438.7795938256493;
f_y = 428.3166621327036;

mu0 = sortedVCorners(1, 1);
mv0 = sortedVCorners(1, 2);

mu1 = sortedVCorners(18, 1);
mv1 = sortedVCorners(18, 2);

mu2 = sortedVCorners(63, 1);
mv2 = sortedVCorners(63, 2);

imgOrig = [sortedVCorners(1, :); sortedVCorners(18, :); sortedVCorners(63, :)];

[mu0, mv0, mk0] = p3pNorm(mu0, mv0, c_x, c_y, f_x, f_y);
[mu1, mv1, mk1] = p3pNorm(mu1, mv1, c_x, c_y, f_x, f_y);
[mu2, mv2, mk2] = p3pNorm(mu2, mv2, c_x, c_y, f_x, f_y);

X0 = world(1, 1);
Y0 = world(1, 2);
Z0 = world(1, 3);

X1 = world(18, 1);
Y1 = world(18, 2);
Z1 = world(18, 3);

X2 = world(63, 1);
Y2 = world(63, 2);
Z2 = world(63, 3);

worldX = [X0, Y0, Z0; X1, Y1, Z1; X2, Y2, Z2];

distances = [];
distances = [distances; sqrt((X1 - X2)^2 + (Y1 - Y2)^2 + (Z1 - Z2)^2)];
distances = [distances; sqrt((X0 - X2)^2 + (Y0 - Y2)^2 + (Z0 - Z2)^2)];
distances = [distances; sqrt((X1 - X0)^2 + (Y1 - Y0)^2 + (Z1 - Z0)^2)];

cosines = [];
cosines = [cosines; (mu1*mu2 + mv1*mv2 + mk1*mk2)];
cosines = [cosines; (mu0*mu2 + mv0*mv2 + mk0*mk2)];
cosines = [cosines; (mu1*mu0 + mv1*mv0 + mk1*mk0)];
% solve the length of PA PB and PC
lengths = lengthSolver(distances, cosines);

imgX = [];
Rs = [];
ts = [];
% compute the Rotation and translation for each solution
for i = 1 : 4
    imgX = [lengths(i, 1)*[mu0, mv0, mk0];
        lengths(i, 2)*[mu1, mv1, mk1];
        lengths(i, 3)*[mu2, mv2, mk2]];
    [R, t] = rigid_transform_3D(worldX, imgX);
    Rs = [Rs; R];
    ts = [ts; t];
end

global X3 Y3 Z3 mu3 mv3;
X3 = world(35, 1);
Y3 = world(35, 2);
Z3 = world(35, 3);
mu3 = sortedVCorners(35, 1);
mv3 = sortedVCorners(35, 2);

min_reproj = 999999999;
ns = 0;
% iterate through all four solutions to find the one that produces the
% least reprojection errors
for i = 1 : 4
    basicIndex = (i - 1) * 3;
    X3p = Rs((basicIndex + 1), 1) * X3 + Rs((basicIndex + 1), 2) * Y3 + Rs((basicIndex + 1), 3) * Z3 + ts((basicIndex + 1));
    Y3p = Rs((basicIndex + 2), 1) * X3 + Rs((basicIndex + 2), 2) * Y3 + Rs((basicIndex + 2), 3) * Z3 + ts((basicIndex + 2));
    Z3p = Rs((basicIndex + 3), 1) * X3 + Rs((basicIndex + 3), 2) * Y3 + Rs((basicIndex + 3), 3) * Z3 + ts((basicIndex + 3));
    
    mu3p = c_x + f_x * X3p / Z3p;
    mv3p = c_y + f_y * Y3p / Z3p;
    reproj = (mu3p - mu3) * (mu3p - mu3) + (mv3p - mv3) * (mv3p - mv3);
    
    if (i == 0 || abs(min_reproj) > abs(reproj)) 
            ns = i;
            min_reproj = reproj;
    end
end

err_mine = rep_error(Rs(4:6, :), ts(4:6));
% R from OpenCV P3P
R_p3p = [0.9751724927065563, -0.03073146620254604, 0.2193038678489812;
 -0.06618979781684881, -0.9855013514892844, 0.1562241878767766;
 0.2113232598022431, -0.1668612093862306, -0.9630679190320474];
t_p3p = [19.44234760445592, 160.6071508385414, 295.0200953938722];
err_p3p = rep_error(R_p3p, t_p3p);

R_epnp = [0.9906641741585167, -0.01403403102579241, -0.1356006637594024;
 -0.01047654084380424, -0.9995828747533818, 0.02691316762689056;
 -0.1359218015285684, -0.02524128508876093, -0.9903979712198003];
t_epnp = [15.3524522558304, 153.5550546788758, 299.6401600830907];
err_epnp = rep_error(R_epnp, t_epnp);

% calculate reprojection errors
function err = rep_error(R, t)
    global c_x f_x c_y f_y;
    
    global mu3 mv3 X3 Y3 Z3;
    X3p = R(1, 1) * X3 + R(1, 2) * Y3 + R(1, 3) * Z3 + t(1);
    Y3p = R(2, 1) * X3 + R(2, 2) * Y3 + R(2, 3) * Z3 + t(2);
    Z3p = R(3, 1) * X3 + R(3, 2) * Y3 + R(3, 3) * Z3 + t(3);
    
    mu3p = c_x + f_x * X3p / Z3p;
    mv3p = c_y + f_y * Y3p / Z3p;
    err = (mu3p - mu3) * (mu3p - mu3) + (mv3p - mv3) * (mv3p - mv3);
end

% expects row data, find rotation and translation between any two
% coordinate system based on a set of point correspondances
function [R,t] = rigid_transform_3D(A, B)
    if nargin ~= 2
	    error('Missing parameters');
    end

    %assert(size(A) == size(B));

    centroid_A = mean(A);
    centroid_B = mean(B);

    N = size(A,1);

    H = (A - repmat(centroid_A, N, 1))' * (B - repmat(centroid_B, N, 1));

    [U,S,V] = svd(H);

    R = V*U';

    if det(R) < 0
        fprintf('Reflection detected\n');
        V(:,3) = V(:,3) * -1;
        R = V*U';
    end

    t = -R*centroid_A' + centroid_B';
end

function lengths = lengthSolver(distances, cosines)
    p = cosines(1) * 2;
    q = cosines(2) * 2;
    r = cosines(3) * 2;
    
    a = (distances(1)^2) / (distances(3)^2);
    b = (distances(2)^2) / (distances(3)^2);
    
    a2 = a * a, b2 = b * b, p2 = p * p, q2 = q * q, r2 = r * r;
    pr = p * r, pqr = q * pr;
    
    if (p2 + q2 + r2 - pqr - 1 == 0)
        error('failed to pass reality check');
    end
    
    ab = a * b, a_2 = 2*a;
    A = -2 * b + b2 + a2 + 1 + ab*(2 - r2) - a_2;
    if (A == 0) 
        error('A is 0!');
    end
    
    a_4 = 4*a;
    B = q*(-2*(ab + a2 + 1 - b) + r2*ab + a_4) + pr*(b - b2 + ab);
    C = q2 + b2*(r2 + p2 - 2) - b*(p2 + pqr) - ab*(r2 + pqr) + (a2 - a_2)*(2 + q2) + 2;
    D = pr*(ab-b2+b) + q*((p2-2)*b + 2 * (ab - a2) + a_4 - 2);
    E = 1 + 2*(b - a - ab) + b2 - b*p2 + a2;
    
    temp = (p2*(a-1+b) + r2*(a-1-b) + pqr - a*pqr);
    b0 = b * temp * temp;
    if (b0 == 0)
        error('b0 equals to 0!');
    end
    quartic_roots = roots([A, B, C, D, E]);
    % check if roots contain solutions
    r3 = r2*r, pr2 = p*r2, r3q = r3 * q;
    inv_b0 = 1. / b0;
    lengths = [];
    for i = 1 : 4
       x = quartic_roots(i);
       if(x <= 0)
           continue;
       end
       
       x2 = x*x;
       b1 = ((1-a-b)*x2 + (q*a-q)*x + 1 - a + b) * ...
            (((r3*(a2 + ab*(2 - r2) - a_2 + b2 - 2*b + 1)) * x + ...
            (r3q*(2*(b-a2) + a_4 + ab*(r2 - 2) - 2) + pr2*(1 + a2 + 2*(ab-a-b) + r2*(b - b2) + b2))) * x2 + ...
            (r3*(q2*(1-2*a+a2) + r2*(b2-ab) - a_4 + 2*(a2 - b2) + 2) + r*p2*(b2 + 2*(ab - b - a) + 1 + a2) + pr2*q*(a_4 + 2*(b - ab - a2) - 2 - r2*b)) * x + ...
            2*r3q*(a_2 - b - a2 + ab - 1) + pr2*(q2 - a_4 + 2*(a2 - b2) + r2*b + q2*(a2 - a_2) + 2) + ...
            p2*(p*(2*(ab - a - b) + a2 + b2 + 1) + 2*q*r*(b + a_2 - a2 - ab - 1)));
       if (b1 <= 0)
            continue;
       end
       y = inv_b0 * b1;
       v = x2 + y*y - x*y*r;
       if (v <= 0)
            continue;
       end
       Z = distances(2) / sqrt(v);
       X = x * Z;
       Y = y * Z;
       
       lengths = [lengths; X Y Z];
    end
    
end
% do normalization for preparing P3P
function [mu, mv, mk] = p3pNorm(mu, mv, c_x, c_y, f_x, f_y)
    mu = (mu - c_x) / f_x;
    mv = (mv - c_y) / f_y;
    norm = sqrt(mu * mu + mv * mv + 1);
    mk = 1 / norm;
    mu = mu / norm;
    mv = mv / norm;
end
