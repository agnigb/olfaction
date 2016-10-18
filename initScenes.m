nscenes = psim.nscenes;    
nmix = psim.nmix;
       
fprintf(1,'initScenes:\n');
if ~exist('doLoad','var')
    doLoad = true;
end

if doLoad
    sScene = ['scene' num2str(pnet.nc) '_nmix' num2str(nmix) 'x' num2str(nscenes) pscene.sTitle '.mat']; 
    sFileScene = [dirMat 'sims/' sScene];
end

if doLoad && exist(sFileScene,'file')
    load(sFileScene)
    fprintf(1,[' Loaded ' sFileScene '\n']);
else
    cTrueNet = zeros(pnet.nc,nscenes,nmix);
    sTrueNet = zeros(pnet.nc,nscenes,nmix);
    % Testing all single odours
    for iScene = 1:min(nscenes,pnet.nc)
        sTrue = false(pnet.nc,1);% Fix number of present odours
        sTrue(iScene) = true;
        cTrue = zeros(pnet.nc,1);
        cTrue(sTrue) = gamrnd(pscene.alpha_1,1/pscene.beta_1,sum(sTrue),1);     
        cTrueNet(:,iScene,1) = cTrue;
        sTrueNet(:,iScene,1) = sTrue;
    end
    if nscenes>pnet.nc 
        for iScene = pnet.nc+1:nscenes
            sTrue = false(pnet.nc,1);% Fix number of present odours
            sTrue(ceil(rand(1)*pnet.nc)) = true;
            cTrue = zeros(pnet.nc,1);
            cTrue(sTrue) = gamrnd(pscene.alpha_1,1/pscene.beta_1,sum(sTrue),1);      
            cTrueNet(:,iScene,1) = cTrue;
            sTrueNet(:,iScene,1) = sTrue;
        end
    end
    % Choosing random subsets for mixtures
    for iMix = 2:nmix
        for iScene = 1:nscenes
            rperm = randperm(pnet.nc);
            sTrue = false(pnet.nc,1);% Fix number of present odours
            sTrue(rperm(1:iMix)) = true;
            cTrue = zeros(pnet.nc,1);
            cTrue(sTrue) = gamrnd(pscene.alpha_1,1/pscene.beta_1,sum(sTrue),1);  
            sTrueNet(:,iScene,iMix) = sTrue;
            cTrueNet(:,iScene,iMix) = cTrue;
        end
    end

    if doLoad
        save(sFileScene,'pscene','sTrueNet','cTrueNet');
        fprintf(1,[' ˜Created ' sFileScene '\n']);
    else
        fprintf(1,' Created scenes, not saved.')
    end
end


           