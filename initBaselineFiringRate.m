function r0 = initBaselineFiringRate(r0mean, r0std, nr)
global pnet

sFile = ['mats/sims/r0' num2str(r0mean,'%.2g') '_' num2str(r0std, '%.2g') '.mat'];
fprintf(1, 'initBaselineFiringRate:\n');
if exist(sFile,'file')
    load(sFile)
    fprintf(1, [' Loaded ' sFile '\n']);
else
    if pnet.randseed > 0
        fprintf(1, 'Fixed random seed. \n');
        rng(pnet.randseed + 30000)
    end
    r0 = r0mean + r0std*randn(nr,1);
    r0(r0<0) = 0;  
    save(sFile,'r0');
    fprintf(1, [' Saved ' sFile '\n']);
end