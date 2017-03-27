% input params:
% @x: the param that carries all measured coordinates of corners in figure
% @k: the param for k values
function result = undistortPts(x, x_c, y_c, k)
    result = [];
    [m, n] = size(x);
    for i = 1 : m
        x_0 = x(i, 1);
        y_0 = x(i, 2);
        r = sqrt((x_0 - x_c)^2 + (y_0 - y_c)^2);
        L = 1 + k(1) * r + k(2) * r^2 + k(3) * r^3 + k(4) * r^4;
        x_new = x_c + L * (x_0 - x_c);
        y_new = y_c + L * (y_0 - y_c);
        result = [result; [x_new, y_new, 1]];
    end
end