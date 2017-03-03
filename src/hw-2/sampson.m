% this function evaluates the sampson error 

function E_sum = sampson_error( homo_mat)
global A;
global X1;
global X2;
   homo = mat_to_vector(homo_mat);
   % residual cost
   e = A * homo';
   J = jacob(homo_mat, X1, X2);
   E_sum = 0;
   for k = 1 : n
    E = [J(k, 1 : 4)' J(k, 5 : 8)']';
    B = inv(E * E');
    C = [ e(2 * k - 1,1)  e(2 * k,1)];
    F = sqrt(C * B * C');
    E_sum = E_sum + F;
   end
end

function h = mat_to_vector(homo)
    h = [homo(1, 1) homo(1, 2) homo(1, 3) 
        homo(2, 1) homo(2, 2) homo(2, 3)
        homo(3, 1) homo(3, 2) homo(3, 3)];
end