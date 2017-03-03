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
    a = (-1) * homo(2, 1) + h(3, 1) * X1(i, 2);
    b = (-1) * homo(2, 2) + h(3, 2) * X2(i, 2);
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