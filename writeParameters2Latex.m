fid = fopen('table.tex', 'w');
fprintf(fid, '\\begin{tabular}{llc}\\hline \n');
fprintf(fid, 'Parameter  & Value \\\\ \\hline \n');
fprintf(fid, '\\multicolumn{3}{c}{Network}\\\\  \n');
fprintf(fid, 'number of glomeruli & $n_r$ & %g \\\\ \n', pnet.nr); 
fprintf(fid, 'number of odours & $n_c$ & %g \\\\ \n', pnet.nc); 
fprintf(fid, 'Background firing rate & $r_0$ & %g \\\\ \n', pnet.r0 ); 
fprintf(fid, 'Connection probability & $\\epsilon$ & %g \\%\\\\ \n', pnet.wkEps*100); 
fprintf(fid, 'Connection weight sum& $\\tilde w$ & %g \\\\ \n', pnet.wkBar); 
if isfield('walpha',pnet),
    fprintf(fid, 'Dirichlet & $\\alpha$ & %g \\\\ \n', pnet.walpha);   
end
fprintf(fid, 'Time window for spike counts & $t_s$ & %g \\\\ \n', pnet.tSpikeCount); 
fprintf(fid, '   &   \\\\ \\hline \n');     
fprintf(fid, '\\multicolumn{3}{c}{Olfactory scenes}\\\\   \n');  
fprintf(fid, 'Nr of expected odours & $\\pi_s n_c $ & %g \\\\ \n', psim.mExpected );
if isfield(pscene,'alpha_0')
    fprintf(fid, '& $\\alpha_1 = \\alpha_0+1 $ & %g   \\\\ \n', pscene.alpha_0); 
end
fprintf(fid, 'Prior on concentration: & $\\alpha_1  $ & %g   \\\\ \n', pscene.alpha_1); 
fprintf(fid, '& $\\beta_1 = 1/40/n_r $ & %1.2g   \\\\ \n', pscene.beta_1);  
fprintf(fid, '   &   \\\\ \\hline \n');        
fprintf(fid, '\\multicolumn{3}{c}{Approximate (VB) model}\\\\   \n');       
if isfield(psim,'beta_0')
    fprintf(fid, '& $\\beta_0 = \\alpha_0 n_c \\epsilon \\tilde w / n_r / (r_0 - r_0^{\\text{VB}})$ & %g \\\\ \n', psim.beta_0 );    
    fprintf(fid, 'Background firing rate to explain by $\\Gamma_0$ & $r_0^{\\text{VB}}$ & %g \\\\ \n', psim. r0VB); 
end
fprintf(fid, '   &   \\\\ \\hline \n');
fprintf(fid, '\\multicolumn{3}{c}{Simulation}\\\\   \n');    
fprintf(fid, 'Number of scenes for simulations & $$ & %g \\\\ \n', psim.nscenes); 
if isfield(pnet,'tauG'), fprintf(fid, '& $\\tau_G $ & %g \\\\ \n', pnet.tauG*1000); end   
if isfield(pnet,'tauA'), fprintf(fid, '& $\\tau_A $ & %g \\\\ \n', pnet.tauA*1000);    end
if isfield(pnet,'tauM'), fprintf(fid, '& $\\tau_M $ & %g ms \\\\ \n', pnet.tauM*1000); end
if isfield(psim,'dt'), fprintf(fid, 'Euler step & $dt$ & %1.2g \\\\ \n', psim.dt);  end   
if isfield(psim,'T'), fprintf(fid, 'Simulation time & $T$ & %g sec \\\\ \n', psim.T);    end

fprintf(fid, '\\end{tabular}\n');
fclose(fid);