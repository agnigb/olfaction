function yContours = showTable(M, sFig,  cLim, sCols, sRows, sCorner, fSize, t, nxL, nyL, posFig, figVisibleOff);
% Draws a table, sCols describes columns. 
% Input should be structured into dimensions of (pxls, rows, cols).
% Color axis can be fixed for all frames:
% - a two-element vector defines coloraxis directly
% - a two-element cell {val1, val2} defines the
% percentiles of pixel values (across all frames) used for clipping 
% - a single value of cLim defines the number of standard deviation 
% (across all frames) used for clipping (common for all the frames).
% - value 0 means that 2.5--97.5 percentile range will be used.
% - an empty cLim value results in the automatic color scaling,
% different for every frame -> the colorbar will not appear
global n s c nAll p pAll



if isfield(c,'drawRotated')&&c.drawRotated
    do.drawRotated = true;
else
    do.drawRotated = false;
end

if isfield(c,'drawMask')&&c.drawMask
    do.drawMask = true;
    if ~isfield(p,'ROI')
        fprintf(1,'Cannot draw mask, because it''s not defined (as p.ROI)\n');
        do.drawMask = false;
    end
else
    do.drawMask = false;
end

if ~exist('nxL','var')||isempty(nxL)
    if isfield(n,'x')
        nxL = n.x;
    else
        nxL = 1;
    end
end
if ~exist('nyL','var')||isempty(nyL)  
    if isfield(n,'y')
        nyL = n.y;
    else
        nyL = 1;
    end
end

                
if isfield(n,'rpx')&&~isempty(n.rpx)
    rpx = n.rpx;
else
    rpx = 1;
end
if size(M,1)~= nxL*nyL
    s0 = size(M);
    if size(M,1) ~=nxL
        nxL = s0(1);
        nyL = s0(2);
        rpx = 1;
    end
    M = reshape(M,[nxL*nyL,s0(3:end)]); 
end

ncols = size(M,2);   
nrows = size(M,3);
M = M(:,1:ncols,1:nrows);
ix = (1:nxL)*rpx;
iy = (1:nyL)*rpx;

if do.drawRotated 
    nxL0 = nxL;
    nxL = nyL;
    nyL = nxL0;
end



% Default figure name
if ~exist('sCorner','var')%||isempty(sCorner)
    if isfield(s,'preprocessing')
        if isfield(c,'analyse')
            sCorner = [c.analyse s.preprocessing];
        else
            sCorner = s.preprocessing;
        end
    elseif exist('sFig','var')&&~isempty(sFig)
        sCorner = sFig;
    else 
        sCorner = '';
    end
end

if ~exist('sFig','var')||isempty(sFig)
    sFig = sCorner;
end

% Title can be given in numbers - here it's replaced by cell of strings
if ~exist('sCols','var')
    sCols = {};
elseif isnumeric(sCols)
    ssCols = cell(1,length(sCols));
    for iC = 1:length(sCols);
        ssCols{iC} = num2str(sCols(iC));
    end
    sCols = ssCols;   
elseif ischar(sCols)
    sCols = {sCols};
end
for iA = length(sCols)+1:ncols
    eval(['sCols(' int2str(iA)  ')= {' int2str(iA) '};'])
end
 
if ~exist('sRows','var')
    sRows = {};
elseif isnumeric(sRows)
    ssRows = cell(1,length(sRows));
    for iC = 1:length(sRows);
        ssRows{iC} = num2str(sRows(iC));
    end
    sRows = ssRows; 
elseif ischar(sRows)
    sRows = {sRows};
end
for iA = size(sRows,2)+1:nrows
    eval(['sRows(' int2str(iA)  ')= {' int2str(iA) '};'])
end


% Setting up color axis
if nargin < 3 || isempty(cLim) || (length(cLim) > 2)
    cLim = 'auto';  
end

if isfield(pAll,'yLimORI')
    cLimORI = pAll.yLimORI + [0 180];
    %cLimORI = [-90 90];
else
    cLimORI = [-90 90];
end
if isequal(cLimORI,cLim)
   M(M<cLimORI(1))=M(M<cLimORI(1))+180; 
   M(M>cLimORI(2))=M(M>cLimORI(2))-180; 
end


if do.drawMask  
    if do.drawRotated
        ROIL = reshape( reshape(p.ROI,nyL,nxL),nxL*nyL,1);
    else
        ROIL = reshape( reshape(p.ROI,nxL,nyL)',nxL*nyL,1);
    end
    hf=figure('visible','off');
    if isfield(p,'colormap')
        cmap = p.colormap;
    elseif isequal(cLim,cLimORI)
        cmap = colormap('sharmap');
    else
        cmap = colormap('jet');
    end
    close(hf)
end


if isfield(c,'drawBin')&&c.drawBin>1
    vCols = defineBinning(1:ncols,c.drawBin);
    if isequal(cLim,cLimORI)
        MC = reshape(M(:,vCols,:),nxL*nyL,c.drawBin,[],nrows);
        for iF = 1:size(MC,3)
            for iR = 1:nrows
                [rOM, MC(:,1,iF,iR)] = calcReproducibilityOM(MC(:,:,iF,iR));
            end
        end
        M = squeeze(MC(:,1,:,:));
    else
        M = squeeze(mean(reshape(M(:,vCols,:),nxL*nyL,c.drawBin,[],nrows),2));
    end
    ncols = size(M,2); 
    sCols = sCols(1:c.drawBin:end);
end



% Setting up color axis
if ~ischar(cLim) && length(cLim)~=2 || iscell(cLim)
    if do.drawMask 
        cM = reshape(M(p.ROI,:),1,[]);
    else
        cM = reshape(M,1,[]);
    end
    if iscell(cLim)
        cLim = prctile(cM,[cLim{:}],2);
    elseif cLim==0
        cLim = prctile(cM,[2.5 97.5]);
    else
        cLim = nanmean(cM) + nanstd(cM)*cLim*[-1 1];   
    end
end

if sum(isnan(cLim))
    cLim = prctile(cM,[2.5 97.5],2);
    if isnan(cLim)
        fprintf(1,'ACHTUNG! The color values you asked for include NaN!\n'); 
    end
elseif cLim(1)==cLim(2)
    error('Set a different colorscale, cLim(1)=cLim(2)!')
end
 
if isfield(c,'drawContours')&&sum(c.drawContours)
	do.drawContours = true;
	if isfield(pAll,'threshContours')&&~isempty(pAll.threshContours)
		threshContours = pAll.threshContours;
	else
		threshContours = 2;
    end
    
	if isfield(pAll,'cmapContours')&&~isempty(pAll.cmapContours)
		colContours = pAll.cmapContours;
    else
        hf=figure('visible','off');
		colContours = colormap(hot(length(threshContours)));
        colContours(1,:) = 0;
        close(hf)
	end
    
	if isfield(pAll,'widthContours')&&~isempty(pAll.widthContours)
		widthContours = pAll.widthContours;
	else
		widthContours = 2;
	end

	if isfield(p,'contours')&&~isempty(p.contours)
	 	yContours = p.contours;
    else 
        for irow = 1:nrows 
            for icol = 1:ncols
                 if do.drawRotated
                     cL = contourc(  ix,iy,reshape(M(:,icol,irow),nyL,nxL)',threshContours);
                 else
                    cL = contourc(ix, iy, reshape(M(:,icol,irow),nxL,nyL)',threshContours);
                 end
                 yContours{irow,icol} = cL;
            end
		end 
	end
else
	do.drawContours = false;
end


% Probing sizes of all extra objects:
f=figure('units','normalized','Position',[0 0 1 1],'visible','off');
set(f,'units','pixels');
posMonitor = get(f,'Position');

% % % Monitor size:
% % if ~exist('posFig','var')||isempty(posFig)
% %     posMonitor = get(0,'MonitorPosition');
% %     posMonitor([3 4]) = posMonitor([3 4])-10;
% %     if sum(posMonitor)<10
% %     posMonitor = [1 1 1024 1024];
% %     end
% % end
dP = floor(min([20 posMonitor(3)/ncols posMonitor(4)/nrows])/2);
if ~exist('fSize','var')||isempty(fSize)
    fSize  = floor(min(12,posMonitor(3)/dP/ncols+2));
end

wConds = 0;
if exist('sRows','var')&&~isempty(sRows)
    set(gca,'units','pixels','Position',[0 0 10 10])
    for iC = 1:length(sRows)
        h = ylabel(sRows{iC},'FontSize',fSize,'Rotation',0,'Interpreter','none',...
                        'HorizontalAlignment','right','VerticalAlignment','baseline','units','pixels');
        extConds = get(h,'Extent');            
        wConds = max(-extConds(1),wConds);
    end
end

hCBar = 0;
if ~ischar(cLim)|| nrows*ncols==1  
    if ischar(cLim)
        if do.drawRotated
            imagesc(ix, iy,reshape(M',nxL, nyL))
        else
            imagesc(ix, iy,reshape(M,nxL,nyL)')
        end
        cLim = get(gca,'CLim');
    end
    caxis(cLim);
    posColorbar = get(colorbar('Location','North','units','pixels','Position',[10 100 200 dP],'FontSize',fSize),'OuterPosition');
    
    if diff(cLim) < .01 || diff(cLim)>10000
        hCBar = posColorbar(4);
%         y0CB = .75*y0;
    else
        hCBar = .75*posColorbar(4);
%         y0CB = .5*y0;
    end
end

hT = 0;
for iC = 1:length(sCols)
   extTitle =  get(title(sCols{iC},'FontSize',fSize,'VerticalAlignment','bottom','units','pixels'),'Extent');
   hT = max(extTitle(4),hT);
end

hTSub = 0;
if exist('sCorner','var')
    extTitle = get(text(0,0,sCorner,'FontSize',floor(.75*fSize),'Interpreter','none','units','pixels'),'Extent');
    hTSub = extTitle(4);
end
close(f)

% Calculate optimum size:
wExtras = wConds+2*dP;
hExtras = hT+hTSub+hCBar+2*dP;
if (posMonitor(3) - wExtras)*nrows*nyL>ncols*nxL*(posMonitor(4)-hExtras)
    hFig = posMonitor(4);
    dPBar = min(dP,1/10*(hFig-hExtras)/nrows);
    hCBar = dPBar+hCBar-dP;
    hP = (hFig-(hT+hTSub+hCBar+2*dP))/nrows;
    wP = nxL/nyL*hP;
    wFig = wP*ncols + wExtras;
else
    wFig = posMonitor(3);
    wP = (wFig-wExtras)/ncols;
    hP = nyL/nxL*wP;
    hFig = hP*nrows+hExtras;
    dPBar = min(dP,1/2*(hFig-hExtras)/nrows);
    hCBar = dPBar+hCBar-dP;
end

% Normalise the size:
hP = hP/hFig;
wP = wP/wFig;
xP0 = wConds/wFig;
yP0 = (hCBar+hTSub+dP)/hFig;

if ~exist('t','var')||isempty(t)
    t = 1;
end

if isfield(c,'visibleOff')&&c.visibleOff
    do.visible = 'off';
else
    do.visible = 'on';
end
figure('Name', sFig,'Position',[0 0 wFig hFig],'visible',do.visible);
if exist('figVisibleOff','var')&&figVisibleOff
    set(gcf,'visible','off')
end
if exist('sCorner','var')
    subplot('Position', [xP0 dP/hFig  wP*ncols .05]);
    text(0,0,sCorner,'FontSize',floor(.75*fSize),'Interpreter','none','units','pixels'); axis off
end
if isfield(p,'colormap')
    colormap(p.colormap);
end

for irow = 1:nrows 
        for icol = 1:ncols
            axes('Position', [xP0+(icol-1)*wP yP0+(nrows-irow)*hP wP*t hP*t]);
            if ~do.drawMask
                if do.drawRotated
                    imagesc(iy,ix, reshape(M(:,icol,irow),nyL,nxL))
                else
                    imagesc(ix, iy,reshape(M(:,icol,irow),nxL,nyL)')
                end
                caxis(cLim)
            else
                if do.drawRotated
                    I0 = reshape( reshape(M(:,icol,irow),nyL,nxL),nxL*nyL,1);
                else
                    I0 = reshape( reshape(M(:,icol,irow),nxL,nyL)',nxL*nyL,1);
                end
                
                if ischar(cLim)
                    cind=ceil((I0(ROIL,:)-min(I0(ROIL,:)))./(max(I0(ROIL,:))-min(I0(ROIL,:)))*63+1);
                else
                    cind=ceil((I0(ROIL,:)-cLim(1))./diff(cLim)*63+1);
                end
                cind(cind<1) = 1;
                cind(cind>64) = 64;
                I(ROIL,:) = cmap(cind,:);
                I(~ROIL,:) = .8;
                
                if do.drawRotated
                    imagesc('CData',reshape(I,nyL,nxL,[]),'XData',iy,'YData',ix); 
                else
                    imagesc('CData',reshape(I,nyL,nxL,[]),'XData',ix,'YData',iy);
                end
                set(gca,'YDir','reverse')
                set(gca,'Layer','top')
                axis tight 
                if isfield(p,'axisOff')
                    if p.axisOff 
                        axis off
                    end
                elseif isfield(pAll,'axisOff')&&pAll.axisOff 
                    axis off
                end
                box on
            end
            
            if do.drawContours
                if ~isempty(yContours)
                    if icol<=length(yContours)%&& ~isempty(yContours{iP})
                        drawContours(yContours{irow,icol},colContours,threshContours,widthContours,do.drawRotated)
                    end
                end
            end
            if do.drawRotated
                set(gca,'XDir','reverse')
            end
            set(gca,'FontSize',4);
            
            set(gca,'YTickLabel',[],'XTickLabel',[]);
%             if icol~=1
%                 set(gca,'YTickLabel',[]);
%             end
%             if irow~=nrows
%                 set(gca,'XTickLabel',[]);
%             end
            if irow==1
                h_title=title(sCols{icol},'FontSize',fSize,'units','normalized');
                posT = get(h_title,'Position');
                set(h_title,'VerticalAlignment','bottom','Position',[posT(1) 1 0]);
            end
%             if exist('sRows','var')
            if icol==1
                if ~exist('xyTick','var')
                    xTick = get(gca,'XTick');
                    yTick = get(gca,'YTick');
                    dTick = max(diff(xTick(1:2)),diff(yTick(1:2)));
                    xTick = xTick(1):dTick:xTick(end);
                    xyTick = min(xTick(1),yTick(1)):dTick:max(xTick(end),yTick(end));
                end
                
                ylabel(sRows{irow},'FontSize',fSize,'Rotation',0,'Interpreter','none',...
                    'HorizontalAlignment','right','VerticalAlignment','baseline');
            end
            set(gca,'XTick',xyTick,'YTick',xyTick);
            
%             end
            if icol==1&&irow==nrows&&rpx~=1
                if do.drawRotated
                    rectangle('Position',[iy(end)-iy(1)-1 ix(end)-iy(2) 1 iy(1)],'FaceColor',[.99 .99 .99],'EdgeColor',[.99 .99 .99]);
                else
                    rectangle('Position',[ix(2)+iy(2) iy(end)-iy(1) 1 iy(1)],'FaceColor',[.99 .99 .99],'EdgeColor',[.99 .99 .99]);
                end
            end
        end
end

if ~ischar(cLim) || nrows*ncols==1     
    caxis(cLim)     
    hc=colorbar('Location','North','Position',[xP0 (hCBar/2+hTSub+dP)/hFig wP*(ncols-1+t) dPBar/hFig],'FontSize',fSize);
    if  isequal(cLimORI,cLim)
        set(hc,'XTick',cLimORI(1):45:cLimORI(end));%,'XTickLabel',{'-90','-45','0','45','90'})
        colormap sharmap
    elseif isequal([-180 180],cLim)
        set(hc,'XTick',[-180 -90 0 90 180],'XTickLabel',{'-180','-90','0','90','180'})
        colormap sharmap
    end
end
