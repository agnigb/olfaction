function  saveFigures(folderName, suffixName, doEps)

global sAll s c

if ~exist('doEps','var')
    if isfield(c,'saveEps')
        doEps = c.saveEps;
    else
        doEps = 0;
    end
end

if ~exist('folderName','var')
    if ~isfield(s,'dirFigs') || (isempty(s.dirFigs))
        if ~isfield(sAll,'dirFigs') || (isempty(sAll.dirFigs))
            folderName = './';
        else
            folderName = sAll.dirFigs;
        end
    else
        folderName = s.dirFigs;
    end
end
if ~exist('suffixName','var')
    suffixName = '';
elseif ~ischar(suffixName) 
%     stop = suffixName+1;% How many figures to save..
    suffixName = '';
end

if ~exist(folderName,'dir')
    mkdir(folderName);
end

if doEps
    folderNameEPS = defdir([folderName 'eps/']);
end
% get(0,'Children') 
while ~isempty(get(0,'CurrentFigure'))
    fN = get(gcf,'Name');
    if isempty(fN)
        fprintf(1,'Not saving figure with no name. \n');
    else
        fN = [fN suffixName];
        fN(fN=='/')='_';
        figName = [folderName, fN,'.png'];
        fprintf(1,['Saving: ',figName,'\n']);  
    %      set(gcf,'Visible','off');
        set(gcf,'PaperPositionMode','auto')
        saveas(gcf,figName); 
        if doEps
            figName = [folderNameEPS fN '.eps'];
            %saveas(gcf,figName,'epsc2');  
            print(gcf, '-depsc2', '-painters', '-r864', figName);
            fix_lines(figName);    
            fprintf(1,['Created: ', figName,'\n']);
        end
%         if next==stop || isempty(get(gcf,'CurrentAxes'))  
%             next=0 
%         end;
    end
    close(gcf);
end

if doEps
    sCommand = prepareCommand4GS(folderNameEPS);
    fid = fopen([folderNameEPS 'commands4GS.txt'],'wt');
    for iF = 1:length(sCommand)
        fprintf(fid,[sCommand{iF} '\n']);
    end
    fclose(fid);
end


% This is downloaded from Matlab Central

function fix_lines(fname)
% The idea of editing the EPS file to change line styles comes from Jiro
% Doke's FIXPSLINESTYLE (fex id: 17928)
% Improve the style of lines used and set grid lines to an entirely new
% style using dots, not dashes
% The idea of changing dash length with line width came from comments on
% fex id: 5743, but the implementation is mine :)
% $Id: print_pdf.m,v 1.25 2008/12/15 16:52:07 ojw Exp $

% Read in the file
fh = fopen(fname, 'rt');
fstrm = char(fread(fh)');
fclose(fh);

% Make sure all line width commands come before the line style definitions,
% so that dash lengths can be based on the correct widths
% Find all line style sections
ind = [regexp(fstrm, '[\n\r]SO[\n\r]'),... % This needs to be here even though it doesn't have dots/dashes!
       regexp(fstrm, '[\n\r]DO[\n\r]'),...
       regexp(fstrm, '[\n\r]DA[\n\r]'),...
       regexp(fstrm, '[\n\r]DD[\n\r]')];
ind = sort(ind);
% Find line width commands
[ind2 ind3] = regexp(fstrm, '[\n\r]\d* w[\n\r]', 'start', 'end');
% Go through each line style section and swap with any line width commands
% near by
b = 1;
m = numel(ind);
n = numel(ind2);
for a = 1:m
    % Go forwards width commands until we pass the current line style
    while b <= n && ind2(b) < ind(a)
        b = b + 1;
    end
    if b > n
        % No more width commands
        break;
    end
    % Check we haven't gone past another line style (including SO!)
    if a < m && ind2(b) > ind(a+1)
        continue;
    end
    % Are the commands close enough to be confident we can swap them?
    if (ind2(b) - ind(a)) > 8
        continue;
    end
    % Move the line style command below the line width command
    fstrm(ind(a)+1:ind3(b)) = [fstrm(ind(a)+4:ind3(b)) fstrm(ind(a)+1:ind(a)+3)];
    b = b + 1;
end

% Find any grid line definitions and change to GR format
% Find the DO sections again as they may have moved
ind = int32(regexp(fstrm, '[\n\r]DO[\n\r]'));
if ~isempty(ind)
    % Find all occurrences of what are believed to be axes and grid lines
    ind2 = int32(regexp(fstrm, '[\n\r] *\d* *\d* *mt *\d* *\d* *L[\n\r]'));
    if ~isempty(ind2)
        % Now see which DO sections come just before axes and grid lines
        ind2 = repmat(ind2', [1 numel(ind)]) - repmat(ind, [numel(ind2) 1]);
        ind2 = any(ind2 > 0 & ind2 < 12); % 12 chars seems about right
        ind = ind(ind2);
        % Change any regions we believe to be grid lines to GR
        fstrm(ind+1) = 'G';
        fstrm(ind+2) = 'R';
    end
end

% Isolate line style definition section
first_sec = findstr(fstrm, '% line types:');
[second_sec remaining] = strtok(fstrm(first_sec+1:end), '/');
[dummy remaining] = strtok(remaining, '%');

% Define the new styles, including the new GR format
% Dot and dash lengths have two parts: a constant amount plus a line width
% variable amount. The constant amount comes after dpi2point, and the
% variable amount comes after currentlinewidth. If you want to change
% dot/dash lengths for a one particular line style only, edit the numbers
% in the /DO (dotted lines), /DA (dashed lines), /DD (dot dash lines) and
% /GR (grid lines) lines for the style you want to change.
new_style = {'/dom { dpi2point 1 currentlinewidth 0.08 mul add mul mul } bdef',... % Dot length macro based on line width
             '/dam { dpi2point 2 currentlinewidth 0.04 mul add mul mul } bdef',... % Dash length macro based on line width
             '/SO { [] 0 setdash 0 setlinecap } bdef',... % Solid lines
             '/DO { [1 dom 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dotted lines
             '/DA { [4 dam 1.5 dam] 0 setdash 0 setlinecap } bdef',... % Dashed lines
             '/DD { [1 dom 1.2 dom 4 dam 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dot dash lines
             '/GR { [0 dpi2point mul 4 dpi2point mul] 0 setdash 1 setlinecap } bdef'}; % Grid lines - dot spacing remains constant
new_style = sprintf('%s\r', new_style{:});

% Save the file with the section replaced
fh = fopen(fname, 'wt');
fprintf(fh, '%s%s%s%s', fstrm(1:first_sec), second_sec, new_style, remaining);
fclose(fh);
return

