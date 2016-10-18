function [xFit, yFit, pFit] = fitWithConstraint(x, y, b)

if ~exist('b','var')
    b = 1;
end

pFit = polyfit(x, y, 1);
if sum(pFit) > b % constraint  y(1) = a*1 + b > 1
    pFit(2) = 1;
    pFit(1) = (sum(x.*y)-b*sum(x))/sum(x.^2); 
end

xFit = x;
yFit = polyval(pFit, xFit);