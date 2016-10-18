function [c1All, c0All] = collectTrueFalseValues(templatec, sTrueNet)


global psim

[nc, nscenes, nmix] = size(templatec);

if nmix == 1
    c1All = templatec(sTrueNet>0);
    c0All = templatec(sTrueNet<1);
else
    c1All = cell(nmix,1);
    c0All = c1All; 
 
    for iM  = 1:nmix
        if isfield(psim,'mix0') &&  psim.mix0 % If there are no odours!
            iMix = iM-1;
            c1 = zeros(iMix,nscenes);
            c0 = zeros(nc-(iMix),nscenes);
            if iMix == 0
                c0 = templatec(:,:,1); % No odour presented.
            else
                for iScene = 1:nscenes
                    c1(:,iScene) = templatec(sTrueNet(:,iScene,iMix)>0,iScene,iM); 
                    c0(:,iScene) = templatec(sTrueNet(:,iScene,iMix)<1,iScene,iM);
                end
            end        
        else
            iMix = iM;
            c1 = zeros(iMix,nscenes);
            c0 = zeros(nc-iMix,nscenes);
            for iScene = 1:nscenes
                c1(:,iScene) = templatec(sTrueNet(:,iScene,iMix)>0,iScene,iMix);
                c0(:,iScene) = templatec(sTrueNet(:,iScene,iMix)<1,iScene,iMix);
            end
        end
        c1All{iM} = c1(:);
        c0All{iM} = c0(:); 
    end 
end
 