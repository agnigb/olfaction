% 
sStable = ['initM0_mF' num2str(mean(mF)) '_' pnet.sWeight '_' pnet.sMGWeight '.mat']; 
sFileStable = [dirMat 'sims/' sStable];

fprintf(1,'runEstimateStablePoint:\n'); 
if exist(sFileStable,'file')
    load(sFileStable)
    fprintf(1,[' Loaded ' sFileStable '\n']);
else
    nt0 = nt;
    nt = .2e5;
    sCounts = diag(pnet.r0)*ones(pnet.nr,nt)*pnet.tSpikeCount; 
    
    eval(psim.sDynamics)   
    
    miSA = mi;
    gkSA = gk;
    alpha_jSA = alpha_j;
    
    % save(sFileStable,'mi','gi','alpha_j','pnet')
    
%     figure('Name','spontaneousActivity')
%     subplot(3,1,1)
%     plot((1:1000:nt)*psim.dt,VB.mT(:,1 :1000:end)')
%     title('MC')
%     subplot(3,1,2)
%     plot((1:1000:nt)*psim.dt,VB.gT(:,1 :1000:end)')
%     title('GC')
%     subplot(3,1,3)
%     plot((1:1000:nt)*psim.dt,VB.aT(:,1 :1000:end)')
%     title( 'PCx')
%     
%     figure('Name','spontaneousActivityMean')
%     subplot(3,1,1)
%     plot((1:1000:nt)*psim.dt,mean(VB.mT(:,1 :1000:end))')
%     title('MC')
%     subplot(3,1,2)
%     plot((1:1000:nt)*psim.dt,mean(VB.gT(:,1 :1000:end))')
%     title('GC')
%     subplot(3,1,3)
%     plot((1:1000:nt)*psim.dt,mean(VB.aT(:,1 :1000:end))')
%     title( 'PCx') 
%     
    nt = nt0;
    save(sFileStable, 'miSA', 'gkSA', 'alpha_jSA')
    fprintf(1,[' Saved ' sFileStable '\n']);
end