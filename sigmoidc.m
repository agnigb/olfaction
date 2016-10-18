function y = sigmoidc(beta,x)

y = 1./(1+exp(-2*beta(1)*(x-beta(2))));