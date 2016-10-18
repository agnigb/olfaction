function mF = initMF(pnet)

fprintf(1, 'initMF:\n');


sFile = ['mats/sims/mF' num2str(pnet.mFmean,'%.2g') '_' num2str(pnet.mFstd, '%.2g') '.mat'];
if exist(sFile,'file')
    load(sFile)
    fprintf(1, [' Loaded ' sFile '\n']);
else
    if pnet.randseed > 0
        fprintf(1, 'Fixed random seed. \n');
        rng(pnet.randseed + 20000)
    end
    mF = lognorm([pnet.nr,1],pnet.mFmean,pnet.mFstd); % Hz
    mF(mF>50) = 50;
%     figure('Name',['histFactors_mFmean' num2str(pnet.mFmean) 'std' num2str(pnet.mFstd)] )
%     hist(mF,pnet.nr)
    save(sFile,'mF');
    fprintf(1, [' Saved ' sFile]);
end