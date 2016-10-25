function  drawFigure7_ROC(ROC, figName, sLegend, xLim)

global pnet psim


if ~isfield(psim,'mix0')
    mix0 = 0;
else
    mix0 = psim.mix0;
end

if exist('xLim','var')
    pscale = pnet.nc;
    if iscell(ROC)
        if ROC{1}(2,1)>1
            pscale = 1;
        end
    else
        if ROC(2,1)>1
            pscale = 1;
        end
    end
else
    pscale = 1;
end

if isnumeric(sLegend)
    sL = cell(length(sLegend),1);
    for iL = 1:length(sLegend)
        sL{iL} = num2str(sLegend(iL));
    end
    sLegend = sL;
end

fSize = 14;


if 1
figure('Name','Figure7','units','centimeters', 'Position',[5 10  17.4*2 6*2],'Visible',psim.figsVisible)
nshow = 4000;
if ~iscell(ROC)
    nmix = size(ROC,3);
    npar = size(ROC,4);
    if nshow > 1
        dshow = floor(size(ROC,2)/nshow);
    else
        dshow = 1;
    end
else
    npar = length(ROC);
    nmix = size(ROC{1},3);
end 
cmap = winter(nmix);
colormap(cmap(end:-1:1,:));
set(gcf,'DefaultAxesColorOrder',cmap);  
nrows = 1;
ncols = ceil((npar+1)/nrows);
% vreverse = size(ROC,3):-1:1;
vreverse = 1:nmix;
for iPar = npar:-1:1 
    subplot(nrows,ncols,iPar)
    if iscell(ROC)
        if nshow > 1
            dshow = floor(size(ROC{iPar},2)/nshow);
        else
            dshow = 1;
        end
        plot(squeeze(ROC{iPar}(2,1:dshow:end,vreverse)*pscale),squeeze(ROC{iPar}(1,1:dshow:end,vreverse)),'-','LineWidth',1)        
    else
        plot(squeeze(ROC(2,1:dshow:end,vreverse,iPar)*pscale),squeeze(ROC(1,1:dshow:end,vreverse,iPar)),'-','LineWidth',1)
    end
    if iPar == (nrows-1)*ncols+1
    ylabel('TP','FontSize',8)
    end
    xlabel('FP','FontSize',8)
    title(sLegend{iPar},'FontSize',fSize), grid on
    set(gca,'Color','none','box','off','YLim',[0 1],'FontSize',fSize) 
end   
if exist('xLim','var'), set(findall(gcf,'Type','axes'),'XLim',xLim), end
for iMix = 1:nmix;
    sMix{iMix} = num2str(iMix-mix0);
end 
legend(sMix(vreverse),'FontSize',fSize,'Location','Best')
end

if mix0
    pOdours = binopdf(1:nmix-1,pnet.nc,psim.pi_s); 
    pOdours = pOdours/sum(pOdours);
    pOdoursFP = binopdf(0:nmix-1,pnet.nc,psim.pi_s); 
    pOdoursFP = pOdoursFP/sum(pOdoursFP);
else
    pOdours = binopdf(1:nmix,pnet.nc,psim.pi_s); 
    pOdours = pOdours/sum(pOdours);
end
if ~iscell(ROC)
    ROCmean = zeros(2,size(ROC,2),npar);
    for iPar = 1:npar
        if ~mix0 
            ROCmean(1,:,iPar) = pOdours*squeeze(ROC(1,:,:,iPar))';
            ROCmean(2,:,iPar) = pOdours*squeeze(ROC(2,:,:,iPar))';
        else
            ROCmean(1,:,iPar) = pOdours*squeeze(ROC(1,:,2:end,iPar))';
            ROCmean(2,:,iPar) = pOdoursFP*squeeze(ROC(2,:,:,iPar))';
        end
    end 
else
    ROCmean = cell(npar,1);
    for iPar = 1:npar
        if ~mix0
            ROCmean{iPar}(1,:) = pOdours*squeeze(ROC{iPar}(1,:,:))';
            ROCmean{iPar}(2,:) = pOdours*squeeze(ROC{iPar}(2,:,:))';
        else
            ROCmean{iPar}(1,:) = pOdours*squeeze(ROC{iPar}(1,:,2:end))';
            ROCmean{iPar}(2,:) = pOdoursFP*squeeze(ROC{iPar}(2,:,:))';
        end
    end 
end

subplot(nrows,ncols,npar+1)
cmap = cool(npar);
cmap(1,:) = [0 0 0];
set(gcf,'DefaultAxesColorOrder',cmap);
if iscell(ROC)
    for iPar = 1:npar
        if nshow > 1
            dshow = floor(size(ROC{iPar},2)/nshow);
        else
            dshow = 1;
        end
        plot(squeeze(ROCmean{iPar}(2,1:dshow:end))*pscale,squeeze(ROCmean{iPar}(1,1:dshow:end)),'-','LineWidth',1,'Color',cmap(iPar,:))
        hold on
    end
else
    plot(squeeze(ROCmean(2,1:dshow:end,:)*pscale),squeeze(ROCmean(1,1:dshow:end,:)),'-','LineWidth',1)
end
ylabel('TP','FontSize',fSize)
xlabel('FP','FontSize',fSize)
grid on
title(['Weighted with P(s)=' num2str(psim.pi_s,'%.2g')])
set(gca,'FontSize',fSize)
if exist('xLim','var'), xlim(xLim), end
legend(sLegend,'FontSize',fSize,'Location','Best','Color','none')
set(gca,'Color','none','box','off','YLim',[0 1])

set(findall(0,'Type','Text'),'FontSize',fSize)
set(findall(0,'Type','Axes'),'TickDir','out')


%scoreFP = mean(FP)

% nTrue = sum(sTrue);
% nc = length(sTrue);
% for ipval = 1:length(vpval)
%     truePos(ipval) = sum(sT(sTrue,iT)>vpval(ipval))/nTrue;
%     falsePos(ipval) = sum(sT(~sTrue,iT)>vpval(ipval))/(nc-nTrue);
% end
% areaROC = sum(diff(falsePos).*(truePos(2:end)+truePos(1:end-1))/2);
