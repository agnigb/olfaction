function drawFigure7_correlations(mTAll, nBin, rTAll, CM0, colMean)
global psim 

[nr, nt, ntrials, nodours] = size(mTAll);

iTrial = ntrials;
vTime = 1:nt;
CMTime = vTime(nBin:nBin:nt); 
% vShow = 50/nBin:20/nBin:length(CMTime)
vShow = 150 + [0, 40, 60, 80, 120, 200, 300]/nBin;

CM = zeros(nt/nBin,nodours,nodours);
 
for iOdour = 1:nodours
    for iOdour2 = 1:iOdour-1
        rT1 = mean(mTAll(:,:,1:iTrial,iOdour),3);
        rT2 = mean(mTAll(:,:,1:iTrial,iOdour2),3);

        rT1 = squeeze(mean(reshape(rT1, nr, nBin,[]),2));
        rT2 = squeeze(mean(reshape(rT2, nr, nBin,[]),2));

        wcc = diag(1/(nr-1)*zscore(rT1)'*zscore(rT2));
        CM(:,iOdour,iOdour2) = wcc; 
        CM(:,iOdour2,iOdour) = wcc; 
    end
end 
 
zORN = zscore(squeeze(mean(mean(rTAll ,3),2))); 
CMORN = 1/(nr-1)*zORN'*zORN-eye(nodours);


x = CMORN; 
pColor = (x-min(x(:)))/(max(x(:))-min(x(:))+.1);

sLegend = {};
for iOdour = 1:nodours
    for iOdour2 = 1:iOdour-1
        sLegend{end+1} = num2str(x(iOdour,iOdour2),'%.2g');
    end
end 
 
figure('Name', 'Figure7B','Position',[111 174 1039  624],'Visible',psim.figsVisible) 
npairs = 0;
sumpairs = zeros(size(CM,1),1);
for iOdour = 1:nodours
    for iOdour2 = 1:iOdour-1 
        c = squeeze(mean(CM(:,iOdour,iOdour2),4));
        sumpairs = c+sumpairs;
        npairs = npairs + 1;
        plot(-psim.T0*1000  + CMTime, c,'Color',pColor(iOdour,iOdour2)*[1 0 0],'LineWidth',2), hold on
        title(['Nr of trials: ' num2str(iTrial)],'FontSize',15)
    end     
end
xlabel('Time [ms]','FontSize',14') 
xlim([-100 300])
ylim([-.5 1])
plot([0 0],[-.6 .8],'k:') 
plot([-150 300],[0 0],'k:')
box off
set(gca,'Color','none','FontSize',12)
legend(sLegend,'Location','BestOutside')
if exist('colMean','var') 
    plot(-psim.T0*1000  + CMTime, sumpairs/npairs ,'Color', colMean,'LineWidth',2), hold on
end

hold on
plot(-psim.T0*1000  + CMTime, sumpairs/npairs ,'Color', 'g','LineWidth',2), hold on
title(['Nr of trials: ' num2str(iTrial)],'FontSize',15)

xlabel('Time [ms]','FontSize',14') 
xlim([-100 300])
ylim([-.5 1])
plot([0 0],[-.6 .8],'k:') 
plot([-150 300],[0 0],'k:')
box off
set(gca,'Color','none','FontSize',12)     

CM1 = permute(CM,[2 3 1 4]);

sTime = {};
time = CMTime(vShow)-psim.T0*1000;
for iT = 1:length(time)
    sTime{end+1} =  num2str(round(time(iT)),'%1g');
end 

cLim = [-.25 .85];
showTable(CM1(:,:,vShow,:),  'Figure7A', cLim, sTime, iTrial)
