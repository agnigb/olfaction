function y = gammapdf(x,a,b)

y = (x.^(a-1).*exp(-b*x)/gamma(a)*b^a);

% Cumulative:
% cdf = gammainc(b*x,a);