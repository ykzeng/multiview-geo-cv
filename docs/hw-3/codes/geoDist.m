% compute the geometric distance between points we got on applying P for
% normalized world frame and those directly from normalization
function [ F ] = geoDist(p,X)
    P = [p(1) p(2) p(3) p(4); 
        p(5) p(6) p(7) p(8); 
        p(9) p(10) p(11) p(12)]; % Intrinsic parameter
    [M,N] = size(X);
    F = zeros(M,N-1);
    for k = 1:M
        Y = P * X(k,:)';
        F(k,1) = Y(1)/Y(3);
        F(k,2) = Y(2)/Y(3);
        F(k,3) = 1;
    end
end