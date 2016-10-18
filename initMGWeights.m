function w = initMGWeights(pnet,dirMat)


fprintf(1, 'initMGWeights:\n');

if ~exist('dirMat','var')
    makeNew = true;
else
    makeNew = false;
end 

sFileWeights = [dirMat 'sims/weightsMG' int2str(pnet.nr) 'x' pnet.sMGWeight '.mat'];
if ~makeNew && exist(sFileWeights,'file')
    load(sFileWeights);
    fprintf(1,[' Loaded ' sFileWeights '\n']);
else
    if pnet.randseed > 0
        fprintf(1, 'Fixed random seed. \n');
        rng(pnet.randseed + 10000)
    end
    nr = pnet.nr;
    ng = pnet.ng;
    noverlap = pnet.ngoverlap;
    poverlap = pnet.pgoverlap;
    
    w = zeros(nr,ng); 
    for ig = 1:ng
        k = ceil(nr/ng*ig);
        vk = k-noverlap:k+noverlap;
        % Circular boundaries
        vk(vk>nr) = vk(vk>nr)-nr;
        vk(vk<1) = vk(vk<1)+nr; 
        vk(rand([2*noverlap+1,1])<poverlap) = k;  
        w(vk,ig) = 1;
    end  
    save(sFileWeights,'w');     
    fprintf(1,[' Created ' sFileWeights '\n']);
end
    