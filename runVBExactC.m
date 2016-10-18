%Exact VB algorithm for the prior on pscene.alpha_0, psim.beta_C

ntExact = psim.ntExact;
% aTVBExact = zeros(pnet.nc,ntExact); 
% mTVBExact = zeros(pnet.nr,ntExact);
%cTVBExact(:,1) =  psim.alpha_C/psim.beta_C;%cBar 

alpha_C = psim.alpha_C;
% alpha_j = psim.pi_s*alpha_C*(ones(pnet.nc,1)+randn(pnet.nc,1)/3);
% alpha_j(alpha_j<0)=1e-4;

wj = sum(w,1);
beta_j = psim.beta_C+wj'; 

logbeta_j = log(beta_j); 
 
%pij = w./repmat(sum(w,2),1,pnet.nc);
pij = ones(size(w))./pnet.nc; 
% To test whether it gets the right answer with the right kick.
 %pij(:,sTrue>0) = 200./pnet.nc;
 %pij = bsxfun(@rdivide,pij,sum(pij,2));
% alpha_j = pscene.alpha_1 *(.9+ .1*rand(pnet.nc,1));
alpha_j = ones(pnet.nc,1)/3;
%alpha_j = alpha_C*ones(pnet.nc,1);%psim.pi_s*
 
g0 = pnet.r0*pnet.tSpikeCount;
VB.aT  = zeros(pnet.nc,ntExact);
% aTVBExact(:,1) =  alpha_j; 
for iT = 1:ntExact   
    
    pij = w.*repmat(exp( (psi(alpha_j) - logbeta_j)'),pnet.nr,1);
    pij = pij./(repmat(g0+sum(pij,2),1,pnet.nc));
     
    VB.aT(:,iT) =  alpha_j; 
    alpha_j =  (r'*pij)' +  alpha_C;
%     subplot(2,1,1)
%     plot(alpha_j,'+r'),%hold on
%     subplot(2,1,2)
%     plot(exp( (psi(alpha_j) - logbeta_j)'),'k'), %hold on
%     title(iT)
%     pause(.7) 
end
% cTVBExact = diag(1./beta_j)*cTVBExact;
 
%tocVBExact = toc;
%fprintf(1,'vBExact done. %.2g sec\n', tocVBExact);

%drawFigure_VBExact
%drawnow
