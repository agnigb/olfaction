initAll
psim.dt = 1e-5  

psim.nscenes = 10; 
 
nt = 45000; 
% rNet  = poissrnd(pnet.r0*pnet.tSpikeCount+w*cTrueNet(:,:,iMix)); 
psim.ntExact = 100;

vT = 1:.001/psim.dt:nt;

psim.nmix = 10;

CC = zeros(psim.ntExact,length(vT),psim.nscenes, psim.nmix);
CCMG = CC;

vConvergeExact = zeros(psim.ntExact-1,psim.nscenes,psim.nmix);
vConvergeVB = zeros(length(vT)-1,psim.nscenes,psim.nmix);
vConvergeMGVB = vConvergeVB; 

zfun = @(x)((x-repmat(mean(x),size(x,1),1))./repmat(std(x),size(x,1),1) );

psim.T0 = 0; 

[cTrueNet, sTrueNet] = initOdourScenes;

for iScene  = 1:psim.nscenes 
for  iMix = 1:6;
      r =  poissrnd( pnet.r0*pnet.tSpikeCount + w*cTrueNet(:,iScene,iMix)); 
    
    runVBExactC 
    sCounts = repmat(r,1,nt); 
      
    runVBNetworkMGC_varinp 
    ha=drawTimeCourses({sCounts,VB.mT,VB.gT,VB.aT},sTrue,[num2str(iMix) '_' num2str(iScene) 'MG'],sLabels,[],psim.vt);
    set(ha(4),'YLim',yLim);
    VBMG = VB;
    aTMGVB = VB.aT(:,vT);
       
    % Check when the algorithm converges.
    vConvergeExact(:,iScene,iMix) = var(diff(aTVBExact'),[],2);
    vConvergeVB(:,iScene,iMix) = var(diff(aTVB'),[],2);
    vConvergeMGVB(:,iScene,iMix) = var(diff(aTMGVB'),[],2);
%     iConverge = find(vVar(1,iScene,iMix)==0,1,'first');
%     if sum(iConverge), vConverge(1,iScene,iMix) = iConverge; end
%     % aTVBExact = aTVBExact(:,1:iConverge); 

    % Compute correlation 
    zaTMGVB = zfun(aTMGVB); %-repmat(mean(aTVB),pnet.nc,1); 
% Need to save aTVBExact within runVBExactC.m
    zaTVBExact = zfun(aTVBExact);  

    CC(:,:,iScene,iMix) = (zaTVBExact'*zaTVB)/pnet.nc;
    CCMG(:,:,iScene,iMix) = (zaTVBExact'*zaTMGVB)/pnet.nc;
    [~,vCC(:,iScene,iMix)] = max(CC(:,:,iScene,iMix)); 
    [~,vCCMG(:,iScene,iMix)] = max(CCMG(:,:,iScene,iMix)); 
    saveFigures('checkpoints/' );

%%
end
end
%%


 
%figure('Name','timeEvolution')
CCmean = mean(CC,3);
CCMGmean = mean(CCMG,3);
for iMix = 1:6%psim.nmix
   figure('Name',num2str(iMix),'Position',[20 20 1000 600])
%    set(gcf,'DefaultAxesColorOrder',spring(psim.nscenes))
   subplot(2,2,1)
   imagesc(CCmean(:,:,iMix)), set(gca,'YDir','normal'), colorbar, caxis([.5 1]), ylim([0 100]),xlim([0 psim.T*1000])
   title('CC to exact')
   xlabel('ms')
   subplot(2,2,2)
   plot(vCC(:,:,iMix)), box off,xlim([0 psim.T*1000]), 
   title('Exact steps in ms')
   xlabel('ms')  
   subplot(2,2,3)
   imagesc(CCMGmean(:,:,iMix)), set(gca,'YDir','normal'), colorbar, caxis([.5 1]), ylim([0 100])
   xlabel('ms')
   subplot(2,2,4)
   plot(vCCMG(:,:,iMix)),xlim([0 psim.T*1000])
   xlabel('ms')  
   set(findall(gcf,'Type','axes') ,'FontSize',15,'TickDir','out','Color','none','box','off')
   set(findall(gcf,'Type','Text') ,'FontSize',16 )
end
%%
figure('Name','summary')
set(gcf,'DefaultAxesColorOrder',spring(6))
subplot 211
plot(squeeze(mean(vCC,2)))
title('VBnetwork mean')
subplot 212
plot(squeeze(mean(vCCMG,2)))
title('VBMG mean')
legend({'1','2','3','4','5','6'})

   set(findall(gcf,'Type','axes') ,'FontSize',15,'TickDir','out','Color','none','box','off')
   set(findall(gcf,'Type','Text') ,'FontSize',16 ) 
 