function [cTrueNet, sTrueNet] = initOdourScenes(cvalues, dirMat)
    global pnet psim pscene

    nscenes = psim.nscenes;    
    nmix = psim.nmix;

    fprintf(1,'initOdourScenes:\n');
    if exist('dirMat','var')
        doLoad = true;
        sScene = [sScene num2str(pnet.nc) '_nmix' num2str(nmix) 'x' num2str(nscenes) pscene.sTitle '.mat']; 
        sFileScene = [dirMat 'sims/' sScene];
    else
        doLoad = false;
        fprintf(1,' dirMat not provided, not storing results \n');
    end

    if exist('cvalues','var')&&~isempty(cvalues)
        fprintf(1,' Drawing concentrations from a subset of cvalues \n');
        doPrior = false;
        sScene = ['sceneLinearCValues_' num2str(min(cvalues),'%.2g') '_' num2str(max(cvalues),'%.2g') '_'];
        ncvalues = length(cvalues);
    else
        fprintf(1,' Drawing concentrations from the prior. \n');
        doPrior = true;
        sScene = 'scene';
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
            cTrueNet(:,iScene,1) = randConcentration(sTrue);
            sTrueNet(:,iScene,1) = sTrue;
        end
        if nscenes>pnet.nc 
            for iScene = pnet.nc+1:nscenes
                sTrue = false(pnet.nc,1);% Fix number of present odours
                sTrue(randperm(pnet.nc, 1)) = true;
                cTrueNet(:,iScene,1) = randConcentration(sTrue);
                sTrueNet(:,iScene,1) = sTrue;
            end
        end
        % Choosing random subsets for mixtures
        for iMix = 2:nmix
            for iScene = 1:nscenes 
                sTrue = false(pnet.nc,1);% Fix number of present odours
                sTrue(randperm(pnet.nc, iMix)) = true; 
                sTrueNet(:,iScene,iMix) = sTrue;
                cTrueNet(:,iScene,iMix) = randConcentration(sTrue);
            end
        end

        if doLoad
            if doPrior 
                save(sFileScene, 'pscene','sTrueNet','cTrueNet');
            else
                save(sFileScene, 'pscene','sTrueNet','cTrueNet','cvalues');
            end
            fprintf(1,[' ˜Created ' sFileScene '\n']);
        else
            fprintf(1,' Created scenes, not saved. \n');
        end
    end

    fprintf(1,'\n');
    
    function cTrue = randConcentration(sTrue)
        cTrue = zeros(pnet.nc,1);
        if doPrior 
            cTrue(sTrue) = gamrnd(pscene.alpha_1,1/pscene.beta_1,sum(sTrue),1); 
        else
            cTrue(sTrue) = cvalues(randperm(ncvalues,sum(sTrue))); 
        end 
                %cTrue(~sTrue) = gamrnd(pscene.alpha_0,1/pscene.beta_0,sum(~sTrue),1);  
    end

end

           