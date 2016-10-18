cTrue = zeros(pnet.nc,1);
sTrue = false(pnet.nc,1);
sTrue(vON) = true;   
% wNew = createCorrelatedOdours(w(:,1)+w(:,2),w,[.5, .4, .3]);
% w(:,4:6) = wNew;
 
cTrue(sTrue) = cValue;
psim.cmapTruth = zeros(pnet.nc,3);
psim.cmapTruth(sTrue>0,:) = cool(sum(sTrue));

psim.sTrue = sTrue; 
psim.vt = 1:round(1/psim.dt/1000):nt; % 1ms 

if psim.runUnknown 
    wUnknown = initUnkownOdour(pnet, dirMat, w, mean(sum(w(:,sTrue))));
end

runTrials

%% Draw figures
if psim.ntrials > 1
    % Plot average timecourses of all variables. 

    [~,isort] = sort(mean(mean(VBk.rTAll,3),2),'descend');
    if psim.runUnknown
        [~,isortU] = sort(mean(mean(VBu.rTAll,3),2),'descend');
        vSamples = [isort([1:4, pnet.nr]); isortU([1:4, pnet.nr])];
    else
        vSamples = isort([1:3, pnet.nr]);
    end

    sLabels = {'ORNs','mitral cells','granule cells','piriform cortex'};

    psim.plotInset = 0;
    ha = drawFigure4_timeCourses({mean(VBk.rTAll,3),mean(VBk.mTAll,3),mean(VBk.gTAll,3),mean(VBk.cTAll,3)},sTrue,'A',sLabels,vSamples);

    if psim.runUnknown 
        hau = drawFigure4_timeCourses({mean(VBu.rTAll,3),mean(VBu.mTAll,3),mean(VBu.gTAll,3),mean(VBu.cTAll,3)},0*sTrue,'C',sLabels, vSamples);
    end

    if psim.runCxoff
        psim.plotInset = 1; 
       haoff = drawFigure4_timeCourses({mean(VBoff.rTAll,3),mean(VBoff.mTAll,3),mean(VBoff.gTAll,3),mean(VBoff.cTAll,3)},sTrue,'B',sLabels, vSamples);
    end

    for iA = 1:length(ha)
        yLim = get(ha(iA),'YLim');
        if psim.runUnknown, yLim = [yLim, get(hau(iA),'YLim')]; end
        if psim.runCxoff, yLim = [yLim, get(haoff(iA),'YLim')]; end 
        yLim = [min(yLim) max(yLim)]; 
        if psim.runUnknown, set([ha(iA) hau(iA)],'YLim',yLim); end
        if psim.runCxoff,set([ha(iA) haoff(iA)],'YLim',yLim);    end 
        plot(ha(iA),[0 0],yLim,':k')
        if psim.runUnknown, plot(hau(iA),[0 0],yLim,':k'), end
        if psim.runCxoff, plot(haoff(iA),[0 0],yLim,':k'), end
    end    
else
    drawFigure2_template 
end
