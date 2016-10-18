% This is a master script, from which all experiments are run.
%
% to save all figures, type
%
%      saveFigures('figs/')
%
% caution: this will close the currently open figures.
%

initAll
 
todo.timecourseSingle = 1;
todo.posterior = 1;
todo.timecourses = 1;
todo.venki = 1;
todo.correlations = 1;
todo.ROC = 1; 

todo.debug = 0;
psim.figsVisible = 'off';

if todo.timecourseSingle  
    % Figures in response to the reviews.
    % Figure 2 in the current graph is based on that data.
    % Comparison of our simulation to the template approach.
    psim.runUnknown = false;
    psim.runCxoff = false; 
    vON = 1:3;
    psim.ntrials = 1;
    cValue = pscene.alpha_1/pscene.beta_1;
    sFile = [dirMat 'sims/timeCourseSingle_net' psim.sSim  '_nON' num2str(length(vON)) '.mat'];
    runEstimateStablePoint
    runTimecourses 
end

if todo.posterior
    % P(s|c), Fig. 3 in the paper.
    psim.nscenes = 10000; 
    if todo.debug
        psim.nscenes = 20;
    end
    sFile = [dirMat 'sims/testPosteriorFromPrior_net' psim.sSim '_nscenes' num2str(psim.nscenes) '.mat'];
    runMixturesFromPrior 
    doLog = 1; 
    [c0hist, c1hist, vc] = histogramOfTrueFalseValues(cVBNet, sTrueNet, doLog);
    drawFigure3A_Psc(c0hist, c1hist, vc, doLog, 'c')
    drawFigure3BC_cInvariance
end

if todo.timecourses
    % Three timecourse figures (Figs 4-6)
    psim.runUnknown = 1;%true;
    psim.runCxoff = 1;%true; 
    psim.ntrials = 10; 
    vON = 1; 
    cValue = pscene.alpha_1/pscene.beta_1;
    sFile = [dirMat 'sims/timeCourses_net' psim.sSim '_nON' num2str(length(vON)) '.mat'];
    runEstimateStablePoint
    runTimecourses 
end

if todo.venki 
    % Venki experiments. Figure 7.
% Venki: the animal decides whether an odour is present in a mixture 
% A mixture of growing complexity 1..16 
% Probability correct - we base decision on single trials.
    doExact = 0;
    psim.nscenes = 500; 
    if doExact 
        psim.sDynamics = 'runVBExactC';
        psim.nscenes = 200;
        psim.ntExact = 50;
    end
    if todo.debug
        psim.nscenes = 3; 
    end
%   Set different values for the concentration of the components.
%   Results generalise over a large range of concentrations.   
%     cValue = pscene.alpha_1/pscene.beta_1 / 12;  
    cValue = .76; 
    if doExact
        sFile = [dirMat 'sims/testVenkiExact_c' num2str(cValue) '_net' psim.sSim '_nscenes' num2str(psim.nscenes) '.mat'];
    else
        sFile = [dirMat 'sims/testVenki_c' num2str(cValue) '_net' psim.sSim '_nscenes' num2str(psim.nscenes) '.mat'];
    end 
    runVenkiExperiment 
end

if todo.correlations  
    % Correlations. Figures 8 and 9
    psim.vt = 1:round(1/psim.dt/1000):nt; % 1ms
    psim.ntrials = 15;
    if todo.debug 
        psim.ntrials = 10;
    end
    cValue = pscene.alpha_1/pscene.beta_1; 
    sFile = [dirMat 'sims/testCorrelations_c' num2str(cValue) '_net' psim.sSim '_nscenes' num2str(psim.ntrials) '.mat'];
    runEstimateStablePoint
    runTrialsCorrelations 
end

if todo.ROC
    % Comparison of different approaches to demixing. 
    % Figure 10.
    psim.nscenes = 1000;   
    if todo.debug
        psim.nscenes = 10;
    end
    sFile = [dirMat 'sims/testROC_300_' psim.sSim '_nscenes' num2str(psim.nscenes) '.mat'];
    doNetworks = 1;
    doSamplingFromPrior = true;
    runMixtures 
end

saveFigures('figs/')
                    
                    
                    
