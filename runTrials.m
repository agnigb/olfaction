% function VB = runTrials(psim.sDynamics, cTrue, w)
% global psim pnet 

VBk.rTAll = zeros(pnet.nr,length(psim.vt),psim.ntrials);
VBk.mTAll = zeros(pnet.nr,length(psim.vt),psim.ntrials);
VBk.gTAll = zeros(pnet.ng,length(psim.vt),psim.ntrials);
VBk.aTAll = zeros(pnet.nc,length(psim.vt),psim.ntrials);
VBk.cTAll = zeros(pnet.nc,length(psim.vt),psim.ntrials);
if isfield(psim,'runUnknown') && sum(psim.runUnknown)
    VBu = VBk;    
end
if isfield(psim,'runCxoff') && sum(psim.runCxoff)
    VBoff = VBk;    
end

for iTrial = 1:psim.ntrials
    sCounts = glomeruliResponseWithBaseline(cTrue,w);
    scaleCortex = 1;
    eval(psim.sDynamics)
    VBk.rTAll(:,:,iTrial) = sCounts(:,psim.vt);
    VBk.mTAll(:,:,iTrial) = VB.mT(:,psim.vt);
    VBk.gTAll(:,:,iTrial) = VB.gT(:,psim.vt);
    VBk.aTAll(:,:,iTrial) = VB.aT(:,psim.vt); 
    VBk.cTAll(:,:,iTrial) = VB.aT(:,psim.vt)./repmat(beta_j,1,length(psim.vt)); %!!!!
     
%     drawFigure4_timeCourses({sCounts,VB.mT,VB.gT,VB.aT},sTrue,'',sLabels);
    if isfield(psim,'runCxoff') && sum(psim.runCxoff) 
        scaleCortex = 100;
        eval( psim.sDynamics )
        scaleCortex = 1;
        VBoff.rTAll(:,:,iTrial) = sCounts(:,psim.vt);
        VBoff.mTAll(:,:,iTrial) = VB.mT(:,psim.vt);
        VBoff.gTAll(:,:,iTrial) = VB.gT(:,psim.vt);
        VBoff.aTAll(:,:,iTrial) = VB.aT(:,psim.vt); 
        VBoff.cTAll(:,:,iTrial) = VB.aT(:,psim.vt)./repmat(beta_j,1,length(psim.vt)); 
    end
    
    if isfield(psim,'runUnknown') && sum(psim.runUnknown) 
        sCounts = glomeruliResponseWithBaseline(max(cTrue),wUnknown);
        eval(psim.sDynamics)
        VBu.rTAll(:,:,iTrial) = sCounts(:,psim.vt);
        VBu.mTAll(:,:,iTrial) = VB.mT(:,psim.vt);
        VBu.gTAll(:,:,iTrial) = VB.gT(:,psim.vt);
        VBu.aTAll(:,:,iTrial) = VB.aT(:,psim.vt); 
        VBu.cTAll(:,:,iTrial) = VB.aT(:,psim.vt)./repmat(beta_j,1,length(psim.vt)); 
    end
end