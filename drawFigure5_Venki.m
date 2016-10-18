function drawFigure5_Venki(aVenkiGO, aVenkiNOGO, aLabel, va, vTestOdours, cValue, pLapse)
% For all trials (black line) slope = -0.0082, intercept = 0.9574.
% For Go trials (blue curve) slope = -0.0018, intercept = 0.9916
% For NoGo trials (red curve) slope = -0.015, intercept = 0.925
global psim

fitsVenki = [-.0018, .9916;
             -.015, .925;
             -.0082, .9574];
if ~exist('pLapse','var')
    pLapse = 0;
end 
         
lw = 1.5;
fs = 8; 
nBackgroundOdours = size(aVenkiGO,3);
nScenes = size(aVenkiGO, 2);
for ia = 1:length(va) 
    aThresh = va(ia);
    figure('Name','Figure5','units', 'centimeters', 'Position',[5   5   8.5  5], 'Visible', psim.figsVisible) 
    set(gca,'Color','none','FontSize', fs)
    hold on 
    pGO = zeros(1,nBackgroundOdours);
    pNOGO = pGO;
    stdGO = pGO;
    stdNOGO = pGO;
    pMEAN = pGO; 
    for iMix = 1:nBackgroundOdours
        aGO = aVenkiGO(vTestOdours(1),:,iMix)>aThresh | aVenkiGO(vTestOdours(2),:,iMix)>aThresh;
        aNOGO = aVenkiNOGO(vTestOdours(1),:,iMix)<aThresh & aVenkiNOGO(vTestOdours(2),:,iMix)<aThresh; % Both alphas need to be lower than threshold, to avoid false positives.
        vNOGO = find(aNOGO>0); 
        vLapse = rand(size(vNOGO))<pLapse;
        aNOGO(vNOGO(vLapse)) = 0;
         
        pGO(iMix) = mean(aGO(:));
        stdGO(iMix) = std(aGO(:));
        pNOGO(iMix) = mean(aNOGO(:));
        stdNOGO(iMix) = std(aNOGO(:)); 
        plot(iMix*[1 1],pGO(iMix)+[-1 1]*stdGO(iMix)/(nScenes^.5), '-b','LineWidth',lw); 
        plot(iMix*[1 1],pNOGO(iMix)+[-1 1]*stdNOGO(iMix)/(nScenes^.5), '-r','LineWidth',lw); 
        pMEAN(iMix) = pGO(iMix)/2 + pNOGO(iMix)/2;
        stdMEAN = sqrt(stdGO(iMix)^2 + stdNOGO(iMix)^2)/2;
        plot(iMix*[1 1],pMEAN(iMix)+[-1 1]*stdMEAN/(nScenes^.5), '-k','LineWidth',lw);  
    end
    x = 1:nBackgroundOdours;
    plot(x, polyval(fitsVenki(1,:),x), ':b', 'LineWidth',lw);  
    plot(x, polyval(fitsVenki(2,:),x), ':r', 'LineWidth',lw);
    plot(x, polyval(fitsVenki(3,:),x), ':k', 'LineWidth',lw); 
    
    [xGO, yGO] = fitWithConstraint(x, pGO, 1); 
    if xGO(1) > 1
        plot([1 xGO(1)], [1 1], '-b', 'LineWidth', lw)
    end
    [xNOGO, yNOGO] = fitWithConstraint(x, pNOGO, 1);
     
    yMEAN = (yNOGO + yGO)/2;
    
    plot(x, yMEAN, '-k', 'LineWidth', lw);  
    plot(xNOGO, yNOGO, '-r', 'LineWidth',lw);  
    plot(xGO, yGO, '-b', 'LineWidth', lw); 
    
    plot(x, pGO, '.b', 'MarkerSize', 8);  
    plot(x, pNOGO, '.r', 'MarkerSize', 8);    
    plot(x, pMEAN, '.k', 'MarkerSize', 8);   
     
    ylim([0.5, 1]) 
    title([aLabel ' thresh=' num2str(aThresh) ', cTrue=' num2str(cValue), ', pLapse=', num2str(pLapse)],'FontSize', fs)
    set(gca,'FontSize',fs, 'XTick', [1, 5, 10, 14], 'YTick', .5:.1:1) 
    xlabel('Number of odours','FontSize',fs)
    ylabel('P(correct)','FontSize',fs)
end
% 
