vOdours = [1 3 5]; 
figure('Name','Figure3B', ...
        'Position', [86   191   450   407], ...
	'Visible', psim.figsVisible)
vColors = {'r','g','b'};
sLegend = {};
for k = 1:length(vOdours)
    nOdours = vOdours(k);
    vexp = sum(cTrueNet> 0) == nOdours;
    cT = cTrueNet(:, vexp); 
    cT = cT(:);
    vind = cT>0;
    cT = cT(vind);
    
    cVB = cVBNet(:, vexp);
    cVB = cVB(:);
    cVB = cVB(vind);
    
    plot(cT, cVB, ['.', vColors{k}], 'MarkerSize',7)
    hold on
    sLegend{k} = [ num2str(nOdours), ' odour presented'];
    save(['cVB_nOdours', num2str(nOdours), '.txt'], 'cVB', '-ASCII')
    save(['cTrue_nOdours', num2str(nOdours), '.txt'], 'cT', '-ASCII')
end 

legend(sLegend)
xlim([0 20])
ylim([0 20])
grid on
box off
set(gca,'Color','None','FontSize',13) 
xlabel('True concentration','FontSize',12)
ylabel('Inferred mean concentration','FontSize',13) 
ha = gca;
c = copyobj(ha,get(ha,'Parent'));

f = figure('Name', 'Figure3C', ...
            'Position', [586   191   450   407], ...
	    'Visible', psim.figsVisible);
copyobj(c, f)
legend(sLegend)
xlim([0 3])
ylim([0 3])
