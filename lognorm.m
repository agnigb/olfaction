function x = lognorm(sizex, mux, stdx)

[muy, stdy] = lognorm2norm(mux, stdx);

x = exp(randn(sizex)*stdy+muy);
