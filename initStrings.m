function pnetL = initStrings(pnetL)
global pnet psim pscene

isGlobal = false;
if ~exist('pnetL','var')
    pnetL = pnet;
    isGlobal = true;
end

if isfield(psim,'beta_0')
    psim.sVB =  ['VB_rB' num2str(psim.r0VB) '_betaB' num2str(psim.beta_0)];
elseif isfield(psim,'beta_C')
    psim.sVB =  ['VB_alphaC' num2str(psim.alpha_C) '_betaC' num2str(mean(psim.beta_C))];
else
    psim.sVB = '';
end

pnetL.sWeight = [int2str(pnetL.nr) 'x' int2str(pnetL.nc) '_rB' num2str( pnetL.r0mean)... 
    '_wmodel' int2str(pnetL.weightmodel) '_wkEps' num2str(pnetL.wkEps*100)]; 
if pnetL.weightmodel<3
    pnetL.sWeight = [pnetL.sWeight '_alphaDir' num2str(pnetL.walpha)];
end
if pnetL.weightmodel<4
    pnetL.sWeight = [pnetL.sWeight '_wkBar' num2str(pnetL.wkBar) ];
end

if isfield(pnetL,'ng')
    pnetL.sMGWeight = ['ng' num2str(pnetL.ng) '_overlap' num2str(pnetL.ngoverlap) ...
        '_' num2str(pnetL.pgoverlap)];
end

pscene.sTitle =  ['_a' num2str(pscene.alpha_1) '_b' num2str(pscene.beta_1)];  
psim.sSim = [pnetL.sWeight pscene.sTitle psim.sVB];

if isGlobal
    pnet = pnetL;
end