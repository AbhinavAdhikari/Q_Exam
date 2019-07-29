# Q_Exam
### Model code for the Q Exam.
ODE_dydx_parameters folder contains the code for ODE simulation of the transcription-translation process. The run file also exports the TX, TL, [mRNA], [protein] and protein degradation rates for 100 ensembles (user defined number of ensembles). These data are required to solve the FBA problem.
In addition, the experimental constraints (fluxes) for the metabolites and amino acids are calculated using calculate_aa_flux_from_experiment.jl and calculate_metabolite_flux_from_experiment.jl. The example calculated values are stored in calculated_aa_flux.txt and calculated_metabolite_flux.txt. Experimental data required to calculate these fluxes are in the experimental_data folder. 

### Appendix including all the equations and the variables used.
