initModelParameters

[w, wMG, wGM, A] = initWeightsAll(pnet, dirMat);
 
% initScenes
 
pnet.r0 = initBaselineFiringRate(pnet.r0mean, pnet.r0std, pnet.nr);

mF = initMF(pnet);