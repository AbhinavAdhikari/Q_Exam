using PyPlot
using DelimitedFiles
#import experimental data GFP
gfp_exp = readdlm("gfp_FINAL_experimental.csv",',')
gfp_exp_time = gfp_exp[2:end,1]
gfp_exp_mean = gfp_exp[2:end,2]
gfp_exp_sd = gfp_exp[2:end,3]

#import FBA simulation data GFP
gfp_FBA = readdlm("FBA_results.csv",',')
gfp_FBA_time = gfp_FBA[2:end,1]
gfp_FBA_mean = gfp_FBA[2:end,end]


#plot
figure(4) #GFP proten
plot(gfp_FBA_time,gfp_FBA_mean,color="brown", label = "Simulated")
scatter(gfp_exp_time,gfp_exp_mean,color="black", label = "Experiment")
errorbar(gfp_exp_time,gfp_exp_mean,yerr=gfp_exp_sd, linestyle="None",capsize=2,elinewidth=0.5,color="black")
xlabel("Time (hours)")
ylabel("[GFP] (μM)")
title("GFP FBA simulation vs experiment")
# tight_layout()
legend()
savefig("FBA_vs_experiment.pdf")
