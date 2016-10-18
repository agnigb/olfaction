function w = initWeights(pnet,dirMat)

fprintf(1, 'initWeights:\n');
if ~exist('dirMat','var')
    makeNew = true;
else
    makeNew = false;
    if  isfield(pnet,'sWeight')
        dirSim = defdir([dirMat 'sims/']);
        sFileWeights = [dirSim 'weights' pnet.sWeight '.mat'];
    else
        fprintf(1,' No sWeight, creating new weights. \n');
        makeNew = true;
    end
end 


if ~makeNew && exist(sFileWeights,'file')
    load(sFileWeights);
    fprintf(1,[' Loaded ' sFileWeights '\n']);
else
    if pnet.randseed > 0
        fprintf(1, 'Fixed random seed. \n');
        rng(pnet.randseed + 0)
    end
    nr = pnet.nr;
    nc = pnet.nc;
    wkEps = pnet.wkEps;
    wkBar = pnet.wkBar;
    if pnet.weightmodel == 1
        w = zeros(nr,nc); 
        alpha = pnet.walpha;
        if wkEps ==1
            w = sample_dirichlet(alpha*ones(1,pnet.nr), pnet.nc)';
        else
           for k = 1:nc
               sw = rand(nr,1)<wkEps;
               w(sw,k) = sample_dirichlet(alpha*ones(sum(sw)),1);
           end
        end
        w = wkBar*w;
    elseif pnet.weightmodel == 2 
        w = rand(nc,nr);
        % REASON for multiple solutions with nr = 1:
        w = w./repmat(sum(w,2),1,nr);
        w = w';
        w = wkBar*w;
    elseif pnet.weightmodel == 3
        w = zeros(nr,nc);
        w(rand(nr*nc,1)<wkEps) = wkBar;
        % This leaves possibility of identical odours and odours that have no
        % influence on the network whatsoever!
        while find(sum(w,1)==0,1)
            vw = find(sum(w,1)==0);
            for ic = 1:length(vw)
                w(rand(nr,1)<wkEps,vw(ic)) = wkBar;
            end
        end

        % Remove identical odour maps:
        wcenter = (w-repmat(mean(w,1),nr,1))./repmat(std(w),nr,1);
        rho = triu(wcenter'*wcenter/(nr-1),1); % upper diagonal

        [~, i2] = find(rho>(1-1e-10),1);
        while i2
            wNew = zeros(nr,1);
            wNew(rand(nr,1)<wkEps) = wkBar;
            wNcenter = (wNew - mean(wNew))/std(wNew);
            rhoNew = (wNcenter'*wcenter)/(nr-1);
            if max(rhoNew<1)
                w(:,i2) = wNew;
                wcenter(:,i2) = wNcenter;
                rho(1:i2-1,i2) = rhoNew(1:i2-1)';
                rho(i2,i2+1:end) = rhoNew(i2+1:end);
                %rho = triu(rho,1);
            end
            [~, i2] = find(rho>(1-1e-10),1);
        end 
    elseif pnet.weightmodel == 4
        w = false(nr,nc);
        w(rand(nr*nc,1)<wkEps) = true;
    end 
    if exist('sFileWeights','var')
        save(sFileWeights,'w');
        fprintf(1,[' Created ' sFileWeights '\n']);
    end
end
    