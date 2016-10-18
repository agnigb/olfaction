if exist(sFile, 'file')
    load(sFile)
    fprintf(1, ['Loaded ' sFile '\n'])
else
    vTestOdours = [1, 2];
    nBackgroundOdours = 14; 
    backgroundOdours = length(vTestOdours) + (1:nBackgroundOdours); 
    nScenes = psim.nscenes;
    cVenkiGO = zeros(pnet.nc,nScenes,nBackgroundOdours);
    aVenkiGO = zeros(pnet.nc,nScenes,nBackgroundOdours);
    cTrueGO = zeros(pnet.nc,nScenes, nBackgroundOdours);

    % Experiments with target odour present. 
    for iMix = 1:nBackgroundOdours
        for iScene = 1:nScenes
            iTestOdour = (iScene>nScenes/2)+1;
            samples = backgroundOdours(randperm(nBackgroundOdours));
            sTrue = false(pnet.nc,1);% Fix number of present odours
            % Picking target odour:
            sTrue(vTestOdours(iTestOdour)) = true;
            sTrue(samples(1:iMix-1)) = true; % One less than number of components
            cTrue = zeros(pnet.nc,1); 
            cTrue(sTrue) = cValue;
            % Exact VB is orders of magnitude faster than the network
            % version - useful for testing.
            if doExact
               r = poissrnd( (pnet.r0 + w*cTrue) *pnet.tSpikeCount);
            else
               sCounts = glomeruliResponseFast(cTrue,w); 
            end
            eval(psim.sDynamics)
            cVenkiGO(:,iScene,iMix) = mean(VB.aT(:,end),2)./beta_j; 
            aVenkiGO(:,iScene,iMix) = mean(VB.aT(:,end),2); 
            cTrueGO(:,iScene,iMix) = cTrue;
        end
    end
 
    %%
    % Perform experiments with target odour absent:

    cVenkiNOGO = zeros(pnet.nc,nScenes,nBackgroundOdours);
    aVenkiNOGO = zeros(pnet.nc,nScenes,nBackgroundOdours);
    cTrueNOGO = zeros(pnet.nc,nScenes,nBackgroundOdours);
    for iMix = 1:nBackgroundOdours 
        for iScene = 1:nScenes
            samples = backgroundOdours(randperm(nBackgroundOdours));
            sTrue = false(pnet.nc,1);% Fix number of present odours 
            sTrue(samples(1:iMix)) = true; 
            cTrue = zeros(pnet.nc,1); 
            cTrue(sTrue) = cValue;
            % Exact VB is orders of magnitude faster than the network
            % version - useful for testing.
            if doExact
                r = poissrnd(pnet.tSpikeCount *( pnet.r0 + w*cTrue) );
            else
               sCounts = glomeruliResponseFast(cTrue,w); 
            end
            eval(psim.sDynamics)
            cVenkiNOGO(:,iScene,iMix) = mean(VB.aT(:,end),2)./beta_j; 
            aVenkiNOGO(:,iScene,iMix) = mean(VB.aT(:,end),2); 
            cTrueNOGO(:,iScene,iMix) = cTrue;
        end
    end
    save(sFile,'-regexp','^(?!(todo)$).')
end 

%%  Fit results on (c_threshold, p_lapse)
%%
vc = 0:.0001:cValue/10;
vp = 0:.01:.25; 
vc = [vc  cValue/10:.01:cValue];
 
rmsError = zeros(2, length(vc), length(vp));
vMinErr = zeros(2, length(vp));
vcMinErr = vMinErr;
for ip = 1:length(vp)
    for ic = 1:length(vc)
        rmsError(:,ic, ip) = fitVenkiExperiment(cVenkiGO(vTestOdours,:,:), cVenkiNOGO(vTestOdours,:,:), vc(ic), vp(ip));
    end
    [vMinErr(:,ip), vcMinErr(:,ip)] = min(rmsError(:,:,ip),[],2);
end

[globalMin, iGlobalMinP] = min(vMinErr'); 
iGlobalMinC = [vcMinErr(1,iGlobalMinP(1)), vcMinErr(2,iGlobalMinP(2))];
globalMinC = vc(iGlobalMinC);
globalMinP = vp(iGlobalMinP);
   
drawFigure5_Venki(cVenkiGO, cVenkiNOGO, 'cOptimalVenki', globalMinC(1), vTestOdours, cValue, globalMinP(1))
% This would be for the system most efficient in odor mixing:
% drawFigure5_Venki(cVenkiGO, cVenkiNOGO, 'cOptimalMaxP', globalMinC(2), vTestOdours, cValue, globalMinP(2))
