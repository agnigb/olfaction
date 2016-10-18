function [ROC, AROC, c1All, c0All, vcROI]= analyse_ROC(templatec, sTrueNet, nMax) 
% If nMax < 1, FP and TP will be normalised relative to the number of
% present / absent odours per mixture.

global psim

[nc, nscenes, nmix] = size(templatec);
if ~exist('nMax','var')   
    nMax = 1;
end

% 1. First find the range of c-thresholds for all mixtures:
cLim = [min(templatec(:)), max(templatec(:))];
vcROI = [cLim(1)-eps cLim(1):diff(cLim)/1000:cLim(2) cLim(2)]; 
ROC = zeros(2,length(vcROI),nmix);
vMin = ones(nmix,1)+1;
cMax = 0;
[c1All, c0All] = collectTrueFalseValues(templatec, sTrueNet);

for iM  = 1:nmix
    if isfield(psim,'mix0') &&  psim.mix0 % If there are no odours!
        iMix = iM-1;  
    else
        iMix = iM; 
    end 

    cMax = max(cMax,max(c0All{iM}));
    ROC(2,:,iM) = 1-cumsum(histc(c0All{iM},vcROI))/(nc-iMix)/nscenes;
    if nMax > 1 
        ROC(2,:,iM) = ROC(2,:,iM)*(nc-iMix);
    end 
    
    iMax = find(ROC(2,:,iM)>=nMax,1,'last');
    if ~isempty(iMax)
        vMin(iM) = iMax;
    end
end 

cMin = vcROI(min(vMin));
 
vcROI = sort(templatec(templatec>cMin));
vcROI = vcROI(vcROI<=cMax);
dROI = 1;

vcROI = [cLim(1)-eps; cMin; vcROI(1:dROI:end); cLim(2)];

% 2. Compute ROC-s:
ROC = zeros(2,length(vcROI),nmix);
AROC = zeros(nmix,1);
for iMix = 1:nmix
    if isfield(psim,'mix0') &&  psim.mix0
        nOdours = iMix-1;
    else
        nOdours = iMix;
    end

    ROC(1,:,iMix) = 1-cumsum(histc(c1All{iMix},vcROI))/(nOdours)/nscenes;
    ROC(2,:,iMix) = 1-cumsum(histc(c0All{iMix},vcROI))/(nc-nOdours)/nscenes;     
    if nMax > 1 
        ROC(2,:,iMix) = ROC(2,:,iMix)*(nc-nOdours);
    end 
    vROC = find(ROC(2,:,iMix)<=nMax);
    if length(vROC)>1
        AROC(iMix) = -sum(diff(ROC(2,vROC,iMix)).* (ROC(1,vROC(2:end),iMix)+ROC(1,vROC(1:end-1),iMix) ))/2;    
    end
end 
