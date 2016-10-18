function drawFigure6_correlations(y)

global psim
 
fsize = 14;
figure('Name','Figure6','Position',[100 300 800 300],'Visible',psim.figsVisible)
subplot(1,2,1)
plot(y(:,1), 'k'), hold on
plot(y(:,2), 'b')
set(gca,'FontSize',fsize,'Color','none')
xlabel('Cell number','FontSize',fsize)
ylabel('Activity','FontSize',fsize)
yLim = get(gca, 'YLim');
ylim([ 0 yLim(2)]);
xlim([0 161])
box off

subplot(1,2,2)
plot(y(:,1), y(:,2), '.k', 'MarkerSize', 10)
xlabel('Activity for odor 1','FontSize',fsize)
ylabel('Activity for odor 2','FontSize',fsize)
axis equal
box off
r = 1/(size(y,1)-1)*zscore(y(:,1))'*zscore(y(:,2));
title(['r = ', num2str( r,2)], 'FontSize', fsize)
yLim = get(gca,'YLim');
xLim = get(gca, 'XLim');
aLim = [0 max(yLim(2), xLim(2))];
ylim(aLim)
xlim(aLim)
set(gca,'FontSize',fsize,'Color','none','YTick',get(gca,'XTick'))
