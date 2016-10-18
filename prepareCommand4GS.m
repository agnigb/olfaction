function sCommand = prepareCommand4GS(source)

sCommand = [];
isfile = exist(source,'file');
if isfile==2
    sCommand = ['gs -q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' source(1:end-3) 'pdf" -f "' source '"'];
elseif isfile ==7
    fileNames = dir([source '*.eps']);
    for iF = 1:length(fileNames)
        sCommand{iF} = ['gs -q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' fileNames(iF).name(1:end-3) 'pdf" -f "' fileNames(iF).name '"'];
    end
else
    fprintf(1,'Files not found\n');
end
    
