function drawFigure6_correlations(mTAll, rTAll)
global psim 

[nr, nt, ntrials, nodours] = size(mTAll);

vTime = 1:nt;
vShow = 150 + [0, 40, 60, 80, 120, 200, 300];

CM = zeros(nt,nodours,nodours);
 
for iOdour = 1:nodours
    for iOdour2 = 1:iOdour-1
        rT1 = mean(mTAll(:,:,:,iOdour),3);
        rT2 = mean(mTAll(:,:,:,iOdour2),3);

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
 
figure('Name', 'Figure6B','Position',[111 174 1039  624],'Visible',psim.figsVisible) 
npair = 0;
%sumpairs = zeros(size(CM,1),1);
tc = zeros(nt, nodours*(nodours-1));
for iOdour = 1:nodours
    for iOdour2 = 1:iOdour-1 
        npair = npair + 1;
        tc(:,npair) = squeeze(mean(CM(:,iOdour,iOdour2),4));
        plot(-psim.T0*1000  + vTime, tc(:,npair),'Color',pColor(iOdour,iOdour2)*[1 0 0],'LineWidth',2), hold on
    end     
end

xlabel('Time (ms)','FontSize',14') 
xlim([-100 300])
ylim([-.5 1])
plot([0 0],[-.6 .8],'k:') 
plot([-150 300],[0 0],'k:')
box off
set(gca,'Color','none','FontSize',12)
legend(sLegend,'Location','BestOutside')

x = mean(tc(50:100,:),1);
y = mean(tc(200:250,:),1);

[h,p,ci,stats] = ttest2(x, y)

plot(-psim.T0*1000  + vTime, mean(tc,2), 'Color', 'b','LineWidth',2), hold on
title(['Nr of trials: ' num2str(ntrials) ', p=' num2str(p)],'FontSize',15)

CM1 = permute(CM,[2 3 1 4]);

sTime = {};
time = vTime(vShow)-psim.T0*1000;
for iT = 1:length(time)
    sTime{end+1} =  num2str(round(time(iT)),'%1g');
end 

cLim = [-.25 .85];
showTable(CM1(:,:,vShow,:),  'Figure6A', cLim, sTime, ntrials)
