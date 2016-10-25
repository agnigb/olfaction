initAll
 
psim.nmix = 10;
psim.nscenes = 200;
    
%vsigmaLuo =   [0:.1:1 2:10]/10; % Best parameters: .01, .2
%vmLuo =  [0 1/640 10/640 .2:.2:4];
%vsigmaLuo =   [0:.5:5]; % Best parameters: .01, .2
%vmLuo =  [0 1/640 .2:.2:3];
vsigmaLuo =   [0.5:.25:3]; % Best parameters: .01, .2
vmLuo =  [.3:.05:.7];

psim.doPoisson = true;

cVB = zeros(pnet.nc,psim.nscenes,psim.nmix);  
yLuo = zeros(pnet.nc,psim.nscenes,psim.nmix); 
yLuoFull = cVB;   
yFLDA = cVB;
AROCLuo = zeros(psim.nmix,length(vmLuo),length(vsigmaLuo));
AROCLuoFull = AROCLuo;
AROCFLDA = AROCLuo;

initScenes 
sTrueAll = sTrueNet; 


vc = .1:.1:10; % Concentrations likely to be drawn from gamma_prior
pc = gammapdf(vc, pscene.alpha_1, pscene.beta_1); 
for iS= 1:length(vsigmaLuo)
    sigmaLuo = vsigmaLuo(iS);
    for iM = 1:length(vmLuo)
        mLuo = vmLuo(iM);
        rPN = zeros(pnet.nr, pnet.nc, length(vc));
        for iC = 1:length(pc)
            rPN(:,:,iC) = luoPN(w*vc(iC)+repmat(pnet.r0,1,pnet.nc)*pnet.tSpikeCount, sigmaLuo, mLuo,1)*pc(iC); 
        end 
        rPN = sum(rPN,3); 
        % Train the weights:
        wFLDA = FisherLD(rPN);
        wLuo = LuoLDA(rPN);
        wLuoFull = LuoLDAFull(rPN);
        % Test on different odours:
        for iMix = 1:psim.nmix 
            rORN  =  repmat(pnet.r0*pnet.tSpikeCount,1,psim.nscenes)+w*cTrueNet(:,:,iMix) ;  
            if psim.doPoisson
                rORN = poissrnd(rORN);
            end 
%             rPN(:,:,iR,iS,iM) = RLuo.*rORN.^1.5./(SLuo.^1.5 + rORN.^1.5 + MLuo * repmat(mean(rORN),pnet.nr,1));
            yLuo(:,:,iMix) = wLuo'*luoPN(rORN,sigmaLuo,mLuo,1) ; 
            yLuoFull(:,:,iMix) = wLuoFull'*luoPN(rORN,sigmaLuo,mLuo,1) ; 
            yFLDA(:,:,iMix) = wFLDA'*luoPN(rORN,sigmaLuo,mLuo,1) ; 
        end 
        AROCLuo(:,iM,iS)  =  calcAROC(yLuo,sTrueAll,10);   
        AROCLuoFull(:,iM,iS)  =  calcAROC(yLuoFull,sTrueAll,10);   
        AROCFLDA(:,iM,iS)  =  calcAROC(yFLDA,sTrueAll,10);            
    end 
end   

%% 
AROC = zeros(length(vmLuo),length(vsigmaLuo), 3);
pOdours = binopdf(1:nmix,pnet.nc,psim.pi_s); 
pOdours = pOdours/sum(pOdours); 
sTitle = {'Luo full','Luo, d=0','FLDA'};
 
for iS= 1:length(vsigmaLuo) 
    AROC(:,iS,1) = pOdours*AROCLuoFull(:,:,iS);
    AROC(:,iS,2) = pOdours*AROCLuo(:,:,iS);
    AROC(:,iS,3) = pOdours*AROCFLDA(:,:,iS);
end   

% %%% Rmax has no influence: 
% diff(AROCmean,[],3)
% AROCmean = squeeze(AROCmean(:,:,1,:));
    
%%
figure('Name',['aroc_summary' psim.sSim],'Position',[1   62  1440 744])
nr = 1;  
for iy = 1:3
    subplot(3,1,iy)
    imagesc(AROC(:,:,iy)')  
    [vm , vs] = find(max(max(AROC(:,:,iy)))==AROC(:,:,iy));
    
    title({sTitle{iy}, [' m=' mat2str(vmLuo(vm)), ' s=', mat2str(vsigmaLuo(vs))]})
    hold on
    plot(get(gca,'XLim'), vs*[1 1], ':k')
    plot(vm*[1 1], get(gca,'YLim'), ':k')
    set(gca,'YDir','normal')  
    ylabel('\sigma')
    xlabel('m') 
%                     colorbar 
    set(gca,'XTick',1:length(vmLuo),'YTick', 1:length(vsigmaLuo ),'YDir','normal')
    set(gca,'XTickLabel',vmLuo ,'YTickLabel',vsigmaLuo); 
    colorbar
    caxis([0 10])
    colorbar('Position',[0.9340    0.1116    0.0118    0.8118])
end   

%% Comparison of the best 
for iy = 1:3
    [vm , vs ] = find(max(max(AROC(:,:,iy)))==AROC(:,:,iy)); 
 
    fprintf(1,['Best parameters ', sTitle{iy}, ':  \n m = %s \n sigma= %s \n'],mat2str(vmLuo(vm)),mat2str(vsigmaLuo(vs)))
% drawFigure7_ROC(ROCtemplateLuoBest,['_templateLuoBest' testType],sLegend,[0 10]);
% drawFigure7_ROC(squeeze(ROCtemplateLuo(3,1,1,:)),['_templateLuoN' testType],sLegend,[0 10]);
end
 
