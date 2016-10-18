function [c0hist, c1hist, vc] = histogramOfTrueFalseValues(templatec, sTrueNet, doLog)
global psim

[c1All, c0All] = collectTrueFalseValues(templatec, sTrueNet);

if iscell(c1All) % Condition on mixtures
    doMixtures = true;
else
    doMixtures = false;
end
   
if doMixtures
    nmix = psim.nmix;
    mix0 = 0;
    if exist('psim','var') && isfield(psim,'mix0')
        mix0=psim.mix0;
    end
    limc0 = minmaxCell(c0All(1+mix0:end));
    limc1 = minmaxCell(c1All(1+mix0:end));
else
    nmix = 1;
    limc0 = [min(c0All(:)), max(c0All(:))];
    limc1 = [min(c1All(:)), max(c1All(:))];
end

if ~exist('doLog','var')
    doLog = 1;
end
if doLog
    limc0 = log10(limc0);
    limc1 = log10(limc1); 
end
dc = diff(limc0)/200;
vc = limc0(1):dc:limc1(2); 

if doMixtures
 
    c1hist =  zeros(length(vc), nmix);
    c0hist =  zeros(length(vc), nmix); 
    for iMix = 1+mix0 : nmix 
        c1 = c1All{iMix}; 
        c0 = c0All{iMix};   
        if ~doLog 
            c1hist(:,iMix-mix0) = histc( (c1(:)),vc);%/iMix/psim.nscenes;
            c0hist(:,iMix-mix0) = histc( (c0(:)),vc);%/(pnet.nc-iMix)/psim.nscenes;
        else
            c1(c1==0)=1e-13;
            c0(c0==0)=1e-13; 
            c1hist(:,iMix-mix0) = histc(log10(c1(:)),vc);%/iMix/psim.nscenes;
            c0hist(:,iMix-mix0) = histc(log10(c0(:)),vc);%/(pnet.nc-iMix)/psim.nscenes;
        end
    end 
else
    if ~doLog
        c1hist = histc( c1All, vc);%/iMix/psim.nscenes;
        c0hist = histc( c0All, vc);%/(pnet.nc-iMix)/psim.nscenes;
    else
        c1hist = histc( log10(c1All), vc);%/iMix/psim.nscenes;
        c0hist = histc( log10(c0All), vc);%/(pnet.nc-iMix)/psim.nscenes;
    end
end
 