function  AROC = calcAROC(templatec, sTrueNet, nMax) 
% If nMax < 1, FP and TP will be normalised relative to the number of
% present / absent odours per mixture.

[nc, nscenes, nmix] = size(templatec);
if ~exist('nMax','var')   
    nMax = 1;
end

cLim = [min(templatec(:)) max(templatec(:))];
vcROI = [cLim(1):diff(cLim)/1000:cLim(2) cLim(2)];  
vMin = ones(nmix,1)+1;
% cMin = max(vcROI);
cMax = 0;
c1All = cell(nmix,1);
c0All = c1All;
for iMix = 1:nmix
    c1 = zeros(iMix,nscenes);
    c0 = zeros(nc-iMix,nscenes);
    for iScene = 1:nscenes
        c1(:,iScene) = templatec(sTrueNet(:,iScene,iMix)>0,iScene,iMix);
        c0(:,iScene) = templatec(sTrueNet(:,iScene,iMix)<1,iScene,iMix);
    end
    c1All{iMix} = c1(:);
    c0All{iMix} = c0(:);

    cMax = max(cMax,max(c0(:))); 
    ROC2 = 1-cumsum(histc(c0(:),vcROI))/(nc-iMix)/nscenes;
    if nMax > 1 
        ROC2 = ROC2*(nc-iMix);
    end 
    
    iMax = find(ROC2>=nMax,1,'last');
    if ~isempty(iMax)
        vMin(iMix) = iMax;
    end
end 

cMin = vcROI(min(vMin));
 
vcROI = sort(templatec(templatec>cMin));
vcROI = vcROI(vcROI<=cMax); 

dROI = 20;

vcROI = [cLim(1); cMin; vcROI(1:dROI:end); cLim(2)];

ROC = zeros(2,length(vcROI));
AROC = zeros(nmix,1); 
for iMix = 1:nmix 
    ROC(1,:) = 1-cumsum(histc(c1All{iMix},vcROI))/(iMix)/nscenes;
    ROC(2,:) = 1-cumsum(histc(c0All{iMix},vcROI))/(nc-iMix)/nscenes;     
    if nMax > 1 
        ROC(2,:) = ROC(2,:)*(nc-iMix);
    end  
%     ROCa = ROC(:, ROC(2,:)<=nMax);
%     AROC(iMix) = -sum(diff(ROCa(2,:)).* (ROCa(1,2:end)+ROCa(1,1:end-1) ))/2;    
  
    va = find(ROC(2,:)<=nMax);
    AROC(iMix) = -sum(diff(ROC(2,va)).* (ROC(1,va(2:end))+ROC(1,va(1:end-1)) ))/2;    
  
end 

