function ha = drawFigure4_timeCourses(data,sTrue,figName,sLabels,vSamples,vTime) 
% Not showing the first 50 ms
global psim pnet

lw = 1;
fs = 8;
dt = psim.dt*1000;
t0 = int16((psim.T0-.05)*1000);
if ~exist('vTime','var')
    if size(data{1},2)==length(psim.vt)
        vTime = (t0+1):length(psim.vt);
        dt = 1;
    else
        vTime  = ((pnet.tSpikeCount/psim.dt+1):100:size(data{1},2)) ;
    end
end
xTime = vTime*dt-psim.T0*1000;

if ~exist('figName','var')
    figName = [];
end 

if ~exist('sLabels','var')
    sLabels = {'Glomeruli input', 'M-cell response', 'Concentration','\lambda'};
end

if ~exist('vSamples','var')||isempty(vSamples)
    nSamples = 30;
    vSamples = 1:nSamples;
else
    nSamples = length(vSamples);
end
vSamples = reshape(vSamples,[],1);  

psim.cmapTruth = zeros(pnet.nc,3);
psim.cmapTruth(sTrue>0,:) = cool(sum(sTrue));
 
cmapTruth = psim.cmapTruth;
cmapLines = hsv(nSamples);

figure('Name',['Figure4', figName],'units','centimeters','Position',[8 2 8.5 14],'Visible',psim.figsVisible) 
set(gcf,'defaultAxesColorOrder',cmapLines)

for iPlot = 1:length(data)
    ha(iPlot) = subplot(length(data),1,iPlot); 
    y = data{iPlot};
    if size(y,1) == pnet.nc
        set(gcf,'DefaultAxesColorOrder',cmapTruth)
        plot(xTime, y(:,vTime)','LineWidth',1), hold on
        vTrue = find(sTrue>0);
        for iTrue = 1:sum(sTrue)
            iiTrue = vTrue(iTrue);
            plot(xTime, y(iiTrue,vTime)','Color',cmapTruth(iiTrue,:),'LineWidth',lw) 
        end
        
        if isfield(psim,'plotInset') && psim.plotInset
            pp = get(gca,'Position'); 
            axes('Position',[pp(1)+pp(3)-pp(3)/2.5    pp(2)+pp(4)/2    pp(3)/2.5    pp(4)/2]);
            set(gcf,'DefaultAxesColorOrder',psim.cmapTruth)
            plot(xTime, y(:,vTime)','LineWidth',1), hold on
            vTrue = find(sTrue>0);
            for iTrue = 1:sum(sTrue)
                iiTrue = vTrue(iTrue);
                plot(xTime, y(iiTrue,vTime)','Color',cmapTruth(iiTrue,:),'LineWidth',lw) 
            end
            xlim(get(ha(iPlot),'XLim'));
        end
    else
        if size(y,1) == pnet.ng
            nExpand = floor(pnet.ng/pnet.nr);        
            cmapL = reshape(repmat(cmapLines,1,floor(pnet.ng/pnet.nr))',3,[])'; 
            vRange = 1:nExpand;
            vSamplesL = repmat((vSamples-1)*nExpand,1, length(vRange))' + repmat(vRange', 1, length(vSamples));
            vSamplesL = vSamplesL(:);
            vSamplesL(vSamplesL<1) = vSamplesL(vSamplesL<1)+pnet.ng;
            vSamplesL(vSamplesL>pnet.ng) = vSamplesL(vSamplesL>pnet.ng)-pnet.ng; 
        else
            cmapL = cmapLines; 
            vSamplesL = vSamples;
        end
        set(gcf,'DefaultAxesColorOrder',cmapL)
        plot(xTime, y(vSamplesL,vTime)','LineWidth',lw), hold on 
    end  
    title(ha(iPlot), sLabels{iPlot})
    ylabel(ha(iPlot), 'Activity')
    box off
    set(ha(iPlot),'FontSize',fs,'Color','none')
    if isfield(psim,'plotInset') && psim.plotInset && size(y,1) == pnet.ng
        pp = get(gca,'Position'); 
        axes('Position',[pp(1)+pp(3)-pp(3)/2.5    pp(2)+pp(4)/2    pp(3)/2.5    pp(4)/2]);

        set(gcf,'DefaultAxesColorOrder',cmapL)
        plot(xTime, y(vSamplesL,vTime)','LineWidth',lw), hold on
 
        xlim(get(ha(iPlot),'XLim'));
    end     
end
xlabel(ha(iPlot),'Time [ms]')  
set(findall(0,'Type','Axes'),'TickDir','out','box','off','Color','none','FontSize',fs)
set(findall(gcf,'Type','Text'),'FontSize',fs)
