fprintf(1, 'drawFigure2_template:\n');

tTemplate = 1500:1700;   
rNet = mean(sCounts(:,tTemplate),2); 
sTime = ['_tTime' num2str(tTemplate(1)/10 - 150) '_' num2str(tTemplate(end)/10 - 150)];
 
wTemplate = w*diag(1./sqrt(sum(w.^2)));
yTemplate = wTemplate'*rNet;
sFile = ['yTemplate_norm1', '_c', num2str(mean(cTrue(sTrue))) sTime '.txt'];
save(sFile, 'yTemplate', '-ASCII');
fprintf(1,[' Saved: ' sFile, '\n']);

vTime = [170, 200, 300];%, 300]; 
nrows = length(vTime)+1;  

figure('Name','Figure2','Position', [440   177   560   621/2], 'Visible', psim.figsVisible)
subplot(nrows,1,1)
bar(yTemplate,'k')%
xlim([0, pnet.nc])
title({['Concentration:', num2str(mean(cTrue(sTrue))), ...
    ' #odours: ', num2str(sum(sTrue))], ...
    'template'})
set(gca,'Color','none')
box off
yLim = get(gca,'YLim');
subplot(nrows,1,2)
bar(yTemplate(sTrue),'r') 
ylim(yLim)
set(gca,'Color','none')
box off 

cT = VB.aT(:,1:10:end);
cT = cT./repmat(beta_j,1,size(cT,2));
aT = VB.aT(:,1:10:end);
for k = 1:nrows-1     
    subplot(nrows,1,k+1)
    
    bar(cT(:,vTime(k)),'k') 
    xlim([0, pnet.nc])
    title(['network; ', num2str(vTime(k)-150), ' ms after onset' ])
    set(gca,'Color','none')
    stemp = cT(:,vTime(k));
    sFile = ['cbar_j_c', num2str(mean(cTrue(sTrue))), '_t', num2str(vTime(k)-150), '.txt'];
     
    save(sFile, 'stemp', '-ASCII');
    fprintf(1,[' Saved: ' sFile, '\n']);
end
 
