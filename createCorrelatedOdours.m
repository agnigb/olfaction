function y = createCorrelatedOdours(wTemplate,w, goalCorrelations)


nr = size(w,1);
nodours = length(goalCorrelations);
y = zeros(nr, nodours);
vstd = [.5 1 2 3]*mean(wTemplate);
nstd = length(vstd);

nsearch = 1000;
www = zeros(nr,nsearch,nstd);
for istd = 1:nstd
    www(:,:,istd) = randn(nr, nsearch)*vstd(istd);
end
www = www(:,:); 
www = repmat(wTemplate,1,nsearch*nstd) + www;
www(www<0) = 0;

wcc = 1/(nr-1)*zscore(www)'*zscore(wTemplate);
max(wcc)
min(wcc)
for iCorr = 1:length(goalCorrelations)
    [valMin, iMin] = min(abs(wcc-goalCorrelations(iCorr)));
    vCorrelated = www(:,iMin);
    fprintf(1,'createCorrelatedOdours:\n');
    fprintf(1,['Created odour correlated by:', ...
        num2str(1/(nr-1)*zscore(vCorrelated)'*zscore(wTemplate)), ...
        '\n']);
    y(:,iCorr) = vCorrelated;
end
