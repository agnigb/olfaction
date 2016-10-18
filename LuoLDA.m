function WFDA = LuoLDA(w)
% Returns Fisher discriminants for odours.


mu = mean(w,2);
dw = w - repmat(mu, 1, size(w,2));
D = (dw*dw')^(-1); % Inverse covariance
A = diag(w'*D*w);
B = w'*D*mu;
c = mu'*D*mu;

L11 = c./(A*c-B.*B);
L22 = B./(A*c-B.*B);
WFDA = D*(w*diag(L11) - mu*L22');% - L22*mu; 