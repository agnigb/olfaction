function [muN, stdN] =  lognorm2norm(mu, std)

varN = log(std*std/mu/mu+1);
stdN = varN^.5;

muN = log(mu) - varN/2;

