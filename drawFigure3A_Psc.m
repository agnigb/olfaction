function drawFigure3A_Psc(c0hist, c1hist, vc, doLog, varName) 

global psim

if ~exist('varName','var')
    varName = 'c'; 
end
sFig = ['_' varName];

if ~exist('doLog','var') 
    if min(c0hist(:)) < 0
        doLog = true;
        sFig = [sFig 'Log'];
    else
        doLog = false;
    end
end

xLabel = varName;
 
col0 = [.5 .5 .5];

nmix = size(c0hist,2);
cmap = winter(nmix); 

pcMixNan = zeros(length(vc), nmix);
pcMixFit = zeros(length(vc), nmix);  
p0Mix = pcMixNan;
p1Mix = pcMixNan; 
 
for iMix = 1: nmix 
    p0Mix(:,iMix) = c0hist(:,iMix)/sum(c0hist(:,iMix) + c1hist(:,iMix));
    p1Mix(:,iMix) = c1hist(:,iMix)/sum(c0hist(:,iMix) + c1hist(:,iMix));
    pcMix  = p1Mix(:,iMix) ./(p0Mix(:,iMix) + p1Mix(:,iMix)); 
  
    % Fill-in NaN with the neighbouring values.
    vnan = isnan(pcMix); 
    pcMixNan(:,iMix) = interp1(vc (~vnan), pcMix(~vnan), vc ,'linear','extrap');
     
    parmsFit  = nlinfit(vc',pcMixNan(:,iMix),@sigmoidc,[10 0]);    
    pcMixFit(:,iMix) = sigmoidc(parmsFit,vc);  
end
 
fprintf(1,['drawFigure3_Psc:\n Sigmoidal fit: ', num2str(parmsFit)], '\n');
  
figd = figure('Name',['distributions' sFig],'Position',[150 250 1140 340],'Visible',psim.figsVisible);
if doLog
    vc = 10.^(vc);
end
plot(vc, p0Mix(:,iMix), '+','Color',col0,'LineWidth',1), hold on
plot(vc, p1Mix(:,iMix),'+', 'Color',cmap(iMix,:),'LineWidth',1),
xlabel(xLabel, 'FontSize', 16)
set(gca,'Color','none', 'YScale','log') 
if doLog
    set(gca,'XScale','log')
end
box off  
xLim = get(gca,'XLim');
close(figd);
 
 
figure('Name','Figure3A','Position',[150 250 1140 340],'Visible',psim.figsVisible) 
hold on  
plot(vc, pcMixNan(:,iMix),'+k','LineWidth',1) 
plot(vc, pcMixFit(:,iMix) ,'Color',[.4 .5 0],'LineWidth',2)  
xlabel(xLabel, 'FontSize', 16) 
if doLog
    set(gca,'XScale','log')
end
set(gca,'Color','none','XLim', xLim) 
legend({'Data', 'Fit'})
ylim([0 1])
box off
 
set(findall(0,'Type','axes'),'FontSize',14,'TickDir','out')
set(findall(0,'Type','text'),'FontSize',14)
% saveFigures('figs_lin/',num2str(iPar),1) 
