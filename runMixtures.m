psim.nmix = 6; 
psim.ntExact = 50;   

psim.sigmaLuo = 2; 
psim.mLuo = .3; 
 
fprintf(1,'runMixtures:\n');
if  exist(sFile,'file')
    load(sFile)
    fprintf(1,[' Loaded ' sFile '\n']);
else 
    cVB = zeros(pnet.nc,psim.nscenes,psim.nmix);
    aVB = cVB;
    cVBNet = cVB;
    if doNetworks
        runEstimateStablePoint
        cVBNetT = cVB;
        aVBNetT = cVB;
    end

    yTemplate = cVB;
    yCosine = cVB;
    yLuo = cVB;
    yLuoFull = cVB;
    yFDA = cVB;   
    
    vc = .2:.2:10;
    pc = gammapdf(vc, pscene.alpha_1, pscene.beta_1);
    rPN = zeros(pnet.nr, pnet.nc, length(vc));
    for iC = 1:length(pc)
        rPN(:,:,iC) = luoPN((w*vc(iC)+repmat(pnet.r0,1,pnet.nc))*pnet.tSpikeCount,psim.sigmaLuo,psim.mLuo,1)*pc(iC); 
    end 
    rPN = sum(rPN,3); 
    wFDA = FisherLD(rPN);
    wLuo = LuoLDA(rPN);
    wLuoFull = LuoLDAFull(rPN);
    
    wTemplate = w*diag(1./sqrt(sum(w.^2))); 
    
    fprintf(1,' Determined Fisher LDA weights.\n');
    cvalues = exp(-7:1/50:3);     
    if doSamplingFromPrior
        [cTrueNet, sTrueNet] = initOdourScenes;
    else
        [cTrueNet, sTrueNet] = initOdourScenes(cvalues, dirMat);%Responses   
    end 
    
    for iMix = 1:psim.nmix 
        tic 
        rNet = bsxfun(@plus,pnet.r0,w*cTrueNet(:,:,iMix))*pnet.tSpikeCount;   
        rNet = poissrnd(rNet);
        yCosine(:,:,iMix) = wTemplate'*rNet*diag(1./sqrt(sum(rNet.^2))); 
        yTemplate(:,:,iMix) = wTemplate'*rNet; 
        yLuo(:,:,iMix) = wLuo'*luoPN(rNet,psim.sigmaLuo,psim.mLuo,1);
        yLuoFull(:,:,iMix) = wLuoFull'*luoPN(rNet,psim.sigmaLuo,psim.mLuo,1);
        yFDA(:,:,iMix) = wFDA'*luoPN(rNet,psim.sigmaLuo,psim.mLuo,1);  

        % Variational Bayes 
        for iScene = 1: psim.nscenes  
            r = rNet(:,iScene);  % This will be Poisson noise
            runVBExactC%_startLambda;  
            cVB(:,iScene,iMix) =  alpha_j./beta_j; 
            aVB(:,iScene,iMix) =  alpha_j; 
            if doNetworks 
                sCounts = glomeruliResponseWithBaseline(cTrueNet(:,iScene,iMix),w);
                eval(psim.sDynamics)
                cVBNetT(:,iScene,iMix) = mean(VB.aT(:,end),2)./beta_j;
                aVBNetT(:,iScene,iMix) = VB.aT(:,end);
            end
        end 
        toc 
    end 
    save(sFile, '-regexp','^(?!(todo)$).');
    fprintf(1, [' Saved ' sFile '\n']);
end

  


% % % %% Figures for the article  

[ROCtemplate, AUCtemplate] =  analyse_ROC(yTemplate, sTrueNet,100);  
ROC  =  analyse_ROC(cVB, sTrueNet,100); 
ROCCosine =  analyse_ROC(yCosine, sTrueNet,100); 
ROCLuoFull =  analyse_ROC(yLuoFull, sTrueNet,100); 

sLegendM = {'VB', 'Luo', 'Template'};
drawFigure7_ROC({ ROC, ROCLuoFull, ROCCosine}, 'Figure', sLegendM,[0 10])  
