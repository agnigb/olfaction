function y = minmaxCell(cAll)

maxC = 0;
minC = inf;
 
for iMix = 1 : length(cAll)
    c0 = cAll{iMix};
    maxC = max(maxC,max(c0(:)));
    minC = min(minC,min(c0(:))); 
end 

y = [minC, maxC];