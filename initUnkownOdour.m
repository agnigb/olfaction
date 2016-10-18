function wUnknown = initUnkownOdour(pnet, dirMat, w, wKsum)
% Creates a new, unknown odour, at a firing rate similar to wKsum +- 25%.
%wKsum = sum(w(:,sTrue));
wKsum = mean(wKsum);


fprintf(1,'Looking for unknown odour:');
if pnet.randseed > 0
    pnet.randseed = pnet.randseed * 1000;
end
wU = initWeightsAll(pnet, defdir([dirMat 'sims/unknownOdour/'])); 
   
if pnet.randseed > 0
    pnet.randseed = pnet.randseed / 1000;
end

wcc = 1/(pnet.nr-1)*zscore(w)'*zscore(wU);
[~,isort] = sort(mean(wcc));
deltaw = abs(sum(wU(:,isort))- wKsum); % Check for a similar firing rate
imin = isort(find(deltaw/wKsum<.25,1,'first'));
%[cmin,imin] = min(mean(wcc));
wUnknown = wU(:,imin); 
 
sum(wUnknown)
mean(1/(pnet.nr-1)*zscore(w)'*zscore(wUnknown))