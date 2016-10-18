tic

% VB.cT = zeros(pnet.nc,nt); 
% VB.cT(:,1) =  psim.alpha_C/psim.beta_C;%cBar  
alpha_C = psim.alpha_C;
wj = sum(w,1); 
beta_j = psim.beta_C + wj'*pnet.tSpikeCount;  
logbeta_j = log(beta_j);

dtdtauM = psim.dt/pnet.tauM;
dtdtauG = psim.dt/pnet.tauG; 
dtdtauA = psim.dt/pnet.tauA; 

VB.mT  = zeros(pnet.nr,nt);
VB.gT = zeros(pnet.ng,nt);
VB.aT  = zeros(pnet.nc,nt);
 
g0 = pnet.r0*pnet.tSpikeCount; 
if exist('miSA','var')  
%     % THIS INJECTS NOISE: 
    mi = miSA.*(1+.1*randn(size(miSA)));%*std(miSA)
    gk = gkSA.*(1+.1*randn(size(gkSA)));
    mi(mi<0) = 0;
    gk(gk<0) = 0;
    
% % % %     mi = miSA;
% % % %     gk = gkSA;
    alpha_j = mean(alpha_jSA)*(1+.1*randn(size(alpha_jSA)));
    alpha_j(alpha_j<0) = 0;
    
else 
    mi = g0;
    gk = wGM*mi;
    alpha_j = psim.alpha_C.*(1+ .1*rand(pnet.nc,1));
end

if ~exist('scaleCortex','var') 
    scaleCortex = 1;
end

ri = sCounts;
gammaF = 1./mF;
riF = diag(gammaF)*ri;
wFt = (diag(1./gammaF)*w*pnet.tSpikeCount)'/scaleCortex; 
 
gik = (diag(gk)*wGM*diag(mi))';
wGMt = wGM';
At = A*pnet.tSpikeCount;
for iT = 1:nt 
    Fj = exp( -logbeta_j + psi(alpha_j) );
     
    gk = gk + ( -gk + At* Fj )*dtdtauG;  %% +g0!!
    gk(gk<0)=0;
%     gk(gk>giMax) = giMax;
    
    gik = gik + (-gik + wGMt.* (mi * gk')  )*dtdtauG;
    
    mi = mi + ( - mi.*mi.* g0 + riF(:,iT) -mi.*sum(wMG.*gik,2))*dtdtauM;
    mi(mi<0)=0;
%     mi(mi>miMax) = miMax;
    
    alpha_j = alpha_j + (alpha_C - alpha_j  + Fj.* (wFt*(mi.^2))  )*dtdtauA;
     
    VB.aT(:,iT) = alpha_j;
    VB.mT(:,iT) = mi;
    VB.gT(:,iT) = gk; 
end

VB.beta_j = beta_j;
tocVBNetwork = toc;
fprintf(1,'vBNetwork done. %.2g sec\n', tocVBNetwork);
