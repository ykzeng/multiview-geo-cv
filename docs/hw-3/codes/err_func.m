% function for computing geometric distance between pts after removing
% distortion and those in actual measurements
% to do this function, make sure:
% 1. ptsCount is total points we have
% 2. dist2center contains the radius from image center for all pts_count points
% 3. measuredPts contains all measured coordinates of pts_count points
% 4. interPts the interception points of two lines we calculated by cross
% product
% 5. (x_c, y_c): center coordinates for img
function [deviation] = err_func(k)
    global x_c y_c measuredPts interPts dist2center vPtsCount hPtsCount err;
    ptsCount = vPtsCount + hPtsCount;
    deviation = zeros(ptsCount, 1);
    err = 0;
    for i = 1: ptsCount
        L = 1 + k(1) * dist2center(i) + k(2) * dist2center(i)^2 + k(3) * dist2center(i)^3;% + k(4) * dist2center(i)^4;
        x_hat = x_c + L * (measuredPts(i, 1) - x_c);
        y_hat = y_c + L * (measuredPts(i, 2) - y_c);
        
        x_err = x_hat - interPts(i, 1);
        y_err = y_hat - interPts(i, 2);
        
        err = err + sqrt(x_err^2 + y_err^2);
        deviation(2*i - 1) = x_err;
        deviation(2*i) = y_err;
    end
end