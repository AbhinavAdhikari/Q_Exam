#This file calcultes the mean and standard deviation for the TX, TL, mRNA conc, protein conc, protein degradation rates for the ODE over a sample of 100 (user defined) parameters.
#This file also exports these values to text files.
#This file also plots the simulation vs experiment with stnadard deviation of sampling.

#User input variables:
#                       tStop (what time the TX, TL, etc. are required)
#                       sampling_count


include("Balances_Parameter_change.jl")

using ODE

#------------------------------------------------------------------#
#      VARY PARAMETERS                                             #
#------------------------------------------------------------------#
#define array of varied parameters
parameters_lb=Array{Float64}([
0.014   #W_1_P28
10      #W_2_P28
10     #W_repressor
0.3/10  #Ksat_X_P70
57/10   #Ksat_L_P70
0.3     #Ksat_X_P28
57      #Ksat_L_P70
2.7/1.25 #tau_X_P70
0.8/1.25 #tau_L_P70
2.7/1.25 #tau_X_P28
0.8/1.25 #tau_L_P28
60/1000  #R_XT (RNAP)
2.3     #R_LT (Ribosome)
22/60  #Protein half life tagged CLPXP. in hours.
]);

parameters_ub=Array{Float64}([
0.14   #W_1_P28
100      #W_2_P28
200      #W_repressor
0.3/5  #Ksat_X_P70
57/2.5  #Ksat_L_P70
0.3     #Ksat_X_P28
57      #Ksat_L_P70
2.7 #tau_X_P70
0.8 #tau_L_P70
2.7 #tau_X_P28
0.8 #tau_L_P28
75/1000  #R_XT (RNAP)
2.3     #R_LT (Ribosome)
90/60 #Protein half life tagged CLPXP. in hours
]);

#==================================================================#
#      Start ODE                                                   #
#------------------------------------------------------------------#
#Setup Time Vector (in hours)
tStart = 0.0
tStep = 0.1
tStop = 16
tSim = collect(tStart:tStep:tStop)

#Setup initial conditions
x0 = [0.0; #S28 mRNA
      0.0; #CISSRA mRNA
      0.0; #deGFP_ssrA mRNA
      0.0; #S28 protein
      0.0; #CISSRA protein
      0.0; #deGFP_ssrA protein
];

#number of simulations
sampling_count = 100;

#initialize array to vary paramaters
parameters_random = zeros(length(parameters_lb),sampling_count)

#generate random parameters. #each column is a new sampling set.
for i in 1:sampling_count
    for j in 1:length(parameters_lb)
        parameters_random[j,i] = parameters_lb[j] .+ (parameters_ub[j] .- parameters_lb[j]).*rand(1)[1]
    end
end

#initialize arrays to store TX, TL and concentrations for each loop. TX and TL are the endpoint rates for tSim. each column is the endpoint of an ensemble.
TX_store = Array{Any}(undef,1,sampling_count)
TL_store = Array{Any}(undef,1,sampling_count)
X_store = Array{Any}(undef,length(tSim),sampling_count)

#run ODE
for i in 1:sampling_count, j in 1:length(tSim)
    f(t,x) = Balances_Parameter_change(t,x,parameters_random[:,i])
    t,X1 = ode23s(f,x0,tSim; points=:specified)
    X_store[j,i]=X1[j]
    TX_store[1,i]=TX
    TL_store[1,i]=TL
end

#store average, sd of TX TL for a timepoint (tStop) and export to txt file
using Statistics
TX_s28 = [a[1] for a in TX_store]; TL_s28 = [a[1] for a in TL_store]
TX_CISSRA = [a[2] for a in TX_store]; TL_CISSRA = [a[2] for a in TL_store]
TX_gfpssrA = [a[3] for a in TX_store]; TL_gfpssrA = [a[3] for a in TL_store]
TX_mean = [mean(TX_s28); mean(TX_CISSRA); mean(TX_gfpssrA)]
TL_mean = [mean(TL_s28); mean(TL_CISSRA); mean(TL_gfpssrA)]
TX_std = [std(TX_s28); std(TX_CISSRA); std(TX_gfpssrA)]
TL_std = [std(TL_s28); std(TL_CISSRA); std(TL_gfpssrA)]
TX_lower = TX_mean - TX_std
TX_upper = TX_mean + TX_std
TL_lower = TL_mean - TL_std
TL_upper = TL_mean + TL_std
TX_export = ["mean (mM/h)" "mean-sd(mM/h)" "mean+sd(mM/h)" ; TX_mean  TX_lower  TX_upper]
TL_export = ["mean (mM/h)" "mean-sd(mM/h)" "mean+sd(mM/h)" ; TL_mean  TL_lower  TL_upper]
using DelimitedFiles
writedlm("Simulation_data_exported/TX_$(tStop)_h_values_$(sampling_count)_samples.txt",TX_export,',')
writedlm("Simulation_data_exported/TL_$(tStop)_h_values_$(sampling_count)_samples.txt",TL_export,',')

#store all m1:p1 values
m1_all = [a[1] for a in X_store]*1e6 #all m1 values for the different parameters. each row is a time point.
m2_all = [a[2] for a in X_store]*1e6
m3_all = [a[3] for a in X_store]*1e6
p1_all = [a[4] for a in X_store]*1000
p2_all = [a[5] for a in X_store]*1000
p3_all = [a[6] for a in X_store]*1000

#Get mean, standard deviation for the mRNA and protein concentration values.
using Statistics
m1_mean = similar(tSim); m2_mean = similar(m1_mean); m3_mean = similar(m1_mean)
p1_mean = similar(m1_mean);p2_mean = similar(m1_mean);p3_mean = similar(m1_mean)
m1_stdev = similar(m1_mean);m2_stdev = similar(m1_mean);m3_stdev = similar(m1_mean)
p1_stdev = similar(m1_mean);p2_stdev = similar(m1_mean);p3_stdev = similar(m1_mean)
for i in 1:length(tSim)
    m1_mean[i] = mean(m1_all[i,:])
    m2_mean[i] = mean(m2_all[i,:])
    m3_mean[i] = mean(m3_all[i,:])
    p1_mean[i] = mean(p1_all[i,:])
    p2_mean[i] = mean(p2_all[i,:])
    p3_mean[i] = mean(p3_all[i,:])
    m1_stdev[i] = std(m1_all[i,:])
    m2_stdev[i] = std(m2_all[i,:])
    m3_stdev[i] = std(m3_all[i,:])
    p1_stdev[i] = std(p1_all[i,:])
    p2_stdev[i] = std(p2_all[i,:])
    p3_stdev[i] = std(p3_all[i,:])
end

#Store values for all the mRNA and proteins at time tStop (last time point)
mRNA_values_all = ["mean (mM/h)" "mean-sd(mM/h)" "mean+sd(mM/h)" ;
                    m1_mean[end]/1e6 (m1_mean[end]-m1_stdev[end])/1e6 (m1_mean[end]+m1_stdev[end])/1e6 ;
                    m2_mean[end]/1e6 (m2_mean[end]-m2_stdev[end])/1e6 (m2_mean[end]+m2_stdev[end])/1e6 ;
                    m3_mean[end]/1e6 (m3_mean[end]-m3_stdev[end])/1e6 (m3_mean[end]+m3_stdev[end])/1e6 ]

protein_values_all = ["mean (mM/h)" "mean-sd(mM/h)" "mean+sd(mM/h)" ;
                      p1_mean[end]/1000 (p1_mean[end]-p1_stdev[end])/1000 (p1_mean[end]+p1_stdev[end])/1000 ;
                      p2_mean[end]/1000 (p2_mean[end]-p2_stdev[end])/1000 (p2_mean[end]+p2_stdev[end])/1000 ;
                      p3_mean[end]/1000 (p3_mean[end]-p3_stdev[end])/1000 (p3_mean[end]+p3_stdev[end])/1000 ];


writedlm("Simulation_data_exported/mRNA_data_at_$(tStop)_h_$(sampling_count)_samples.txt",mRNA_values_all,',')
writedlm("Simulation_data_exported/protein_data_at_$(tStop)_h_$(sampling_count)_samples.txt",protein_values_all,',')

#get protein degradation rate average, upper and lower bound.
protein_deg_rate_from_half_life_parameters = log(2) ./(parameters_random[end,:]) #converted from half life
protein_deg_rate_mean = mean(protein_deg_rate_from_half_life_parameters)
protein_deg_rate_std = std(protein_deg_rate_from_half_life_parameters)
protein_deg_rate_all = ["mean(per h)" "mean-sd(per h)" "mean+std(per h)";
                        protein_deg_rate_mean (protein_deg_rate_mean-protein_deg_rate_std) (protein_deg_rate_mean+protein_deg_rate_std)];
writedlm("Simulation_data_exported/protein_deg_rate_at_$(tStop)_h_$(sampling_count)_samples.txt",protein_deg_rate_all,',')


#==================================================================#
#      Start Plotting                                              #
#------------------------------------------------------------------#
#
# #Get experimental data
using DelimitedFiles
gfp_experiment = readdlm("gfp_FINAL_experimental.csv",',')
gfp_exp_mean = gfp_experiment[2:end,2]
gfp_exp_time = gfp_experiment[2:end,1]
gfp_exp_stdev = gfp_experiment[2:end,3]

gfp_experiment_mRNA = readdlm("qPCR_table_results_ONLY.csv",',')
gfp_exp_mean_mRNA = gfp_experiment_mRNA[2:end,2]
gfp_exp_time_mRNA = gfp_experiment_mRNA[2:end,1]
gfp_exp_stdev_mRNA = gfp_experiment_mRNA[2:end,3]


using PyPlot
figure(1) #GFP proten
upper_gfp =  p3_mean + p3_stdev
lower_gfp =  p3_mean - p3_stdev
fill_between(tSim, upper_gfp, lower_gfp,color="lightblue", alpha=1)
plot(tSim,p3_mean,color="black", label = "Simulated")
scatter(gfp_exp_time,gfp_exp_mean,color="black", label = "Experiment")
errorbar(gfp_exp_time,gfp_exp_mean,yerr=gfp_exp_stdev, linestyle="None",capsize=2,elinewidth=0.5,color="black")
xlabel("Time (hours)")
ylabel("[GFP] (mM)")
title("GFP simulation vs experiment")
tight_layout()
legend()
savefig("GFP_protein_simulation_vs_experiment.pdf")

figure(2) #GFP mRNA
upper_gfp_mRNA =  m3_mean + m3_stdev
lower_gfp_mRNA =  m3_mean - m3_stdev
fill_between(tSim, upper_gfp_mRNA, lower_gfp_mRNA,color="lightblue", alpha=1)
plot(tSim,m3_mean,color="black", label = "Simulated")
scatter(gfp_exp_time_mRNA,gfp_exp_mean_mRNA,color="black", label = "Experiment")
errorbar(gfp_exp_time_mRNA,gfp_exp_mean_mRNA,yerr=gfp_exp_stdev_mRNA, linestyle="None",capsize=2,elinewidth=0.5,color="black")
xlabel("Time (hours)")
ylabel("[GFP mRNA] (nM)")
title("GFP mRNA simulation vs experiment")
tight_layout()
legend()
savefig("GFP_mRNA_simulation_vs_experiment.pdf")

