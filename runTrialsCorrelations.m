if ~exist(sFile,'file')
 
    nBin = 1;
% % Choosing correlated odour groups to show: 
% %     template = repmat(pnet.r0,1,pnet.nc) + w* cValue;
% %     wcc = 1/(pnet.nr-1)*zscore(template)'*zscore(template);
% %     wcc= wcc-eye(pnet.nc);
% %     d = pdist(template','correlation'); % 1-correlation for non-diag pairs, "squareform" to matrix
% %     Z = linkage(d,'average');
% %     leafOrder = optimalleaforder(Z,d); % optimal leaf order for plotting
% %     figure('Name','patterncorrAll')
% %     imagesc(wcc(leafOrder,leafOrder)); 
% %     colorbar
% %     vo = [15, 14, 16, 39, 38, 40];
% %     vOdours = leafOrder(vo); 
	vOdours = [596   622   309   224   312   628]; 
   
    wNew = createCorrelatedOdours(w(:,vOdours(:,1)),w,[.8, .7, .6]);
    nNew = size(wNew,2);
    psim.nOdoursCM = length(vOdours)+nNew;

    template = repmat(pnet.r0,1,psim.nOdoursCM) + cat(2, wNew, w(:,vOdours)) * cValue;

    VBk.rTAll = zeros(pnet.nr,length(psim.vt),psim.ntrials,psim.nOdoursCM);
    VBk.mTAll = zeros(pnet.nr,length(psim.vt),psim.ntrials,psim.nOdoursCM);
    VBk.gTAll = zeros(pnet.ng,length(psim.vt),psim.ntrials,psim.nOdoursCM);
    VBk.aTAll = zeros(pnet.nc,length(psim.vt),psim.ntrials,psim.nOdoursCM);
    VBk.cTAll = zeros(pnet.nc,length(psim.vt),psim.ntrials,psim.nOdoursCM);


    if isfield(psim,'runUnknown') && sum(psim.runUnknown)
        VBu = VBk;    
    end
    if isfield(psim,'runCxoff') && sum(psim.runCxoff)
        VBoff = VBk;    
    end

    CM0 = zeros(psim.nOdoursCM);
    sLegend={};
    for iOdour = 1:psim.nOdoursCM 
        zOdour1 = zscore(template(:,iOdour));
        for iOdour2 = 1:iOdour-1  
            wcc = 1/(pnet.nr-1)*zOdour1'*zscore(template(:,iOdour2));
            CM0(iOdour,iOdour2) = wcc;
            sLegend{end+1} = num2str(wcc,'%.2g');
        end     
    end 
    pColor = (CM0-min(CM0(:)))/(max(CM0(:))-min(CM0(:))+.1);
    CM0 = CM0 + CM0';
    for iTrial = 1:psim.ntrials
        for iOdour = 1:psim.nOdoursCM
            if iOdour <= nNew
                sCounts = glomeruliResponseWithBaseline(cValue, wNew(:,iOdour));
            else 
                sCounts = glomeruliResponseWithBaseline(cValue,w(:,vOdours(iOdour-nNew))); 
            end    
            eval(psim.sDynamics)
            VBk.rTAll(:,:,iTrial,iOdour) = sCounts(:,psim.vt);
            VBk.mTAll(:,:,iTrial,iOdour) = VB.mT(:,psim.vt);
            VBk.gTAll(:,:,iTrial,iOdour) = VB.gT(:,psim.vt);
            VBk.aTAll(:,:,iTrial,iOdour) = VB.aT(:,psim.vt);  
            VBk.cTAll(:,:,iTrial,iOdour) = VB.aT(:,psim.vt)./repmat(beta_j,1,length(psim.vt));    
        end
        fprintf(1,[num2str(iTrial) '\n']);
    end
    save(sFile, 'VBk', 'nBin')
else
    load(sFile)
    fprintf(1,['Loaded ' sFile '\n']);
end


z = mean(mean(VBk.mTAll,2),3);
drawFigure6_correlations(z(:,[5, 6]))
drawFigure7_correlations(VBk.mTAll, VBk.rTAll)
