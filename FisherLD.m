function WFDA = FisherLD(w)
% Returns Fisher discriminants for odours.


mu = mean(w,2);
%dw = w - repmat(mu, 1, size(w,2));
%D = (dw*dw')^(-1); % Inverse covariance  

D = inv(cov(w'));

WFDA = D*(w - repmat(mu, 1, size(w,2)));% - L22*mu; 