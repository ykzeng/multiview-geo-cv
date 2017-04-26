function [F] = estimate_Fundamental_Matrix(x1,x2,T1,T2)
 n_correspondences = size(x1,1);
 % Normalize the correspondences
 x1_n = (T1*x1')';
 x2_n = (T2*x2')';
 % Stacking up the equations for all the correspondences
 A = zeros(n_correspondences,9);
 for i=1:n_correspondences
 A(i,:) = [x2_n(i,1)*x1_n(i,1) x2_n(i,1)*x1_n(i,2) x2_n(i,1) ...
 x2_n(i,2)*x1_n(i,1) x2_n(i,2)*x1_n(i,2) x2_n(i,2) ...
 x1_n(i,1) x1_n(i,2) 1];
 end
 % Solving for initial estimate of Fundamental Matrix using Linear Least
 % squares by finding SVD of A and choosing the last eigenvector
 [U_lls D_lls V_lls] = svd(A);
 f = V_lls(:,end);
 F_unconditioned = reshape(f,3,3)';
 % Conditioning the Fundamental Matrix to enforce the rank constraint
 [U D V] = svd(F_unconditioned)
 D(end,end) = 0;
 F_conditioned = U*D*V';
 % Denormalizing the Fundamental Matrix
 F = T2'*F_conditioned*T1;
end
