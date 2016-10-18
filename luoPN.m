function [rPN, wFDA] = luoPN(rORN,sigma,m,Rmax)

% Transformation from ORN to PN
% If the second output argument is used, it will learn the classifier.
if ~exist('Rmax','var')
    Rmax = 1;
end

nr = size(rORN,1);

rPN = Rmax.*rORN.^1.5./(sigma.^1.5 + rORN.^1.5 + (m * repmat(mean(rORN),nr,1)).^1.5);
            
if nargout>1
    wFDA = FisherLD(rPN);
end