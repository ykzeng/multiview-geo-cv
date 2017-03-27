% normalization for 2d and 3d space
function [homo,result] = normalize(A,ndim)
    if (ndim == 2)
        nordis = sqrt(2);
    elseif (ndim == 3)
        nordis = sqrt(3);
    else
        printf('we cant handle cases other than 2/3 dimensions');
    end
    [m,n] = size(A);
    % get the centroid of all points
    avg = mean(A);
    % get the sum of distances between pts and centroid
    total = sum(sqrt(sum((A - avg).^2,2)));
    % calculate diagonal element s in similarity homography
    s = m*nordis/total;
    lc = [-s*avg(1) -s*avg(2) 1];
    if (ndim == 3)
        lc = [-s*avg(1) -s*avg(2) -s*avg(3) 1];
    end
    homo = s*eye(n);
    homo(:,n) = lc';
    result = A*homo';
end