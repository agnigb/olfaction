function [sCounts, rTmean] =  glomeruliResponseFast(cTrue,w)
global pnet psim
% Weights are of spike count (per time window).


nt = ceil(psim.T/psim.dt);
nt0 = ceil(pnet.tSpikeCount/psim.dt);


rTmean = pnet.r0 + w*cTrue;

% Baseline spikes
nspikes = ceil(pnet.tSpikeCount*max(pnet.r0)*3);
usp0 = rand(pnet.nr,nspikes);
vsp0 = - log(1-usp0) ./repmat(pnet.r0,1,nspikes)/psim.dt; 
% Add up ISI to get spike times, correct for first array position
vsp0 = round(cumsum(vsp0,2))+1;
vsp0(vsp0(:)>nt0) = 0;

% Firing
nspikes = psim.T*max(rTmean);
nspikes = ceil(nspikes+sqrt(nspikes)*3); % 3std of Poisson distribution
usp = rand(pnet.nr,nspikes);
vsp = -bsxfun(@times,log(1-usp),1./rTmean/psim.dt); 
vsp = round(cumsum(vsp,2))+nt0+1;
vsp(vsp>nt+nt0+1) = 0;
 
 
% Choose spike channels that have at least one spike
vr = find((vsp(:,1)+vsp0(:,1)) > 0);
% and assign spikes to them
 
sCounts = zeros(pnet.nr,nt+2*nt0);
vsp = [vsp0,vsp];
vT = 0:round(pnet.tSpikeCount/psim.dt)-1;
    
for ir = 1:length(vr)
    vspr = vsp(vr(ir),:);
    vspr = vspr(vspr>0); 
    for isp = 1:length(vspr)
        sCounts(vr(ir),vspr(isp)+vT) = sCounts(vr(ir),vspr(isp)+vT)+1;
    end
%     spresponse(vr(ir),vspr)= true;
    
    
end
 
sCounts = sCounts(:,nt0+1:nt0+nt);
%keyboard
% ntCount = round(pnet.tSpikeCount/psim.dt);
% sCounts = filter(ones(ntCount,1),1,spresponse')';


%sCounts = zeros(pnet.nr,nt+nt0)