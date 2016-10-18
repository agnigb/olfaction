fprintf(1,'runMixturesFromPrior:\n');

if  exist(sFile, 'file')
    load(sFile)
    fprintf(1, [' Loaded ' sFile '\n']);
else 
 
    runEstimateStablePoint
    
    aVBNet = zeros(pnet.nc, psim.nscenes); 
    cVBNet = aVBNet;      

    cTrueNet = zeros(pnet.nc, psim.nscenes);
    sTrueNet = zeros(pnet.nc, psim.nscenes);
    % Testing all single odours
    for iScene = 1:psim.nscenes
        sTrue = rand(pnet.nc,1) < psim.pi_s;   
        cTrueNet(sTrue, iScene) = gamrnd(pscene.alpha_1,1/pscene.beta_1,sum(sTrue),1); 
        sTrueNet(:,iScene) = sTrue;
    end 

    % Variational Bayes
    for iScene = 1: psim.nscenes   
        sCounts = glomeruliResponseWithBaseline(cTrueNet(:,iScene),w);
        runVBNetworkMGC_varinp
        cVBNet(:,iScene) = mean(VB.aT(:,end),2)./beta_j;
        aVBNet(:,iScene) = mean(VB.aT(:,end),2);
        fprintf(1,['max true: ', num2str(max(cTrueNet(:,iScene))), '\n']);
        fprintf(1,['max true: ', num2str(max(cVBNet(:,iScene))), '\n']);
    end
    toc  
    save(sFile, '-regexp','^(?!(todo)$).');
    fprintf(1, [' Saved ' sFile '\n']);
end   
 