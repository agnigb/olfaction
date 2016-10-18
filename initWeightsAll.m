function [w, wMG, wGM, A] = initWeightsAll(pnet, dirMat)

fprintf(1,'Creating generative weights.\n');
w = initWeights(pnet,dirMat); 
A = zeros(pnet.ng,pnet.nc);
for iG = 1:pnet.ng
    A(iG,:) = w(ceil(iG/pnet.ng*pnet.nr),:); 
end
wMG = initMGWeights(pnet,dirMat)/sqrt(2*pnet.ngoverlap+pnet.ng/pnet.nr)/4;
wGM = wMG'*4;
w = (wMG.*wGM')*A; 