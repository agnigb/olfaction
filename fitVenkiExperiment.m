function rmsError = fitVenkiExperiment(aVenkiGO, aVenkiNOGO, aThresh, pLapse)
% For all trials (black line) slope = -0.0082, intercept = 0.9574.
% For Go trials (blue curve) slope = -0.0018, intercept = 0.9916
% For NoGo trials (red curve) slope = -0.015, intercept = 0.925
fitsVenki = [-.0018, .9916;
             -.015, .925;
             -.0082, .9574];
nBackgroundOdours = size(aVenkiGO,3);    

pGO = zeros(1,nBackgroundOdours);
pNOGO = pGO;  
for iMix = 1:nBackgroundOdours
    aGO = aVenkiGO(1,:,iMix)>aThresh | aVenkiGO(2,:,iMix)>aThresh;
    aNOGO = aVenkiNOGO(1,:,iMix)<aThresh & aVenkiNOGO(2,:,iMix)<aThresh; % Both alphas need to be lower than threshold, to avoid false positives.
    %aAllGO = aVenkiGO(cTrueGO(:,iMix)>0,:,iMix)>aThresh; 
     
    % Correct NO answers are swapped to eager YES, with probability pLapse
    vNOGO = find(aNOGO>0); 
    nLapse = round(pLapse*length(vNOGO));
    aNOGO(vNOGO(1:nLapse)) = 0;
 
    pGO(iMix) = mean(aGO(:));
    %stdGO(iMix) = std(aGO(:));
    pNOGO(iMix) = mean(aNOGO(:));
    %stdNOGO(iMix) = std(aNOGO(:)); 
end
x = 1:nBackgroundOdours; 
yVenkiGO = polyval(fitsVenki(1,:),x);
yVenkiNOGO = polyval(fitsVenki(2,:),x);

rmsError(1) = sqrt(sum((pGO - yVenkiGO).^2 + (pNOGO - yVenkiNOGO).^2));
rmsError(2) = sqrt(sum((pGO - 1).^2 + (pNOGO - 1).^2));

