close all
clear all 
global psim pnet pscene 

pnet.randseed = 1;

% Baseline firing rate of ORNs
pnet.r0mean = 10;    
pnet.r0std  = 1;

% gamma_i's for MCells: For Cosyne, this was mean1, std1
pnet.mFmean = .5;%(.5, .5)
pnet.mFstd  = .275;

% Over-representation
kRC = 4;

% Number of receptors 
pnet.nr = 160; 
% Number of known odours:
pnet.nc = kRC*pnet.nr; % the last one for the "unknown" odour
% Number of GCs:
pnet.ng = pnet.nr*3; 
pnet.ngoverlap = 1;  % How far can a granule cell reach.
pnet.pgoverlap = .5; % probability of connecting to neighbouring MC.

% Weight matrix w ~ [nr x nc]
% Time window for counting spikes:
pnet.tSpikeCount = .050;
 
pnet.weightmodel = 3;
pnet.wkEps = .2;
pnet.wkBar = 30 * 10 ;  % Strength of weights incrased to please Alex.

pnet.tauM = .01; % mitral cells
pnet.tauA = .01; % alpha cells
pnet.tauG = .005; % granule cells

psim.dt = .0001; % sec 
psim.T0 = 3*pnet.tSpikeCount; % Pre-stimulus time
psim.T = .300+psim.T0;
nt = round(psim.T/psim.dt);
psim.dtstore = 1e-3;
psim.ntstore = round(psim.T/psim.dtstore); 

% Directories for storing results: 
dirMat = defdir('./mats/'); 
defdir([dirMat '/sims/']);  

% Priors:
psim.mExpected = 3;
psim.pi_s = psim.mExpected/pnet.nc; % P(s-present)

% % pscene.beta_0  = 1;% alpha_0+1;
pscene.alpha_1 = 1;
pscene.beta_1  = 1/3;
 
psim.alpha_C = 1/3;
psim.beta_C = psim.alpha_C/pscene.alpha_1*pscene.beta_1/psim.pi_s;

pscene.vc = 0:.5:100;
psim.vt = 1:100:nt;

psim.sDynamics = 'runVBNetworkMGC_varinp'; 

initStrings
