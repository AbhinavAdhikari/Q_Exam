# For reaction list, please refer to Debug.txt


#Species Index for TXTL rates:
# 1 S28
# 2 CISSRA
# 3 deGFP_ssrA
using DelimitedFiles
# ----------------------------------------------------------------------------------- #
function Bounds(DF,timepoint,mean_or_lower_or_upper)
    global protein_deg_rate_data

    #import all TX,TL,mRNA,protein concentration data from ode simulation


    TX_data = readdlm("Simulation_data_TX_TL_mRNA_prot_conc/TX_$(timepoint)_h_values_100_samples.txt",',')[:,mean_or_lower_or_upper]
    TL_data = readdlm("Simulation_data_TX_TL_mRNA_prot_conc/TL_$(timepoint)_h_values_100_samples.txt",',')[:,mean_or_lower_or_upper]
    mRNA_data = readdlm("Simulation_data_TX_TL_mRNA_prot_conc/mRNA_data_at_$(timepoint)_h_100_samples.txt",',')[:,mean_or_lower_or_upper]
    protein_data = readdlm("Simulation_data_TX_TL_mRNA_prot_conc/protein_data_at_$(timepoint)_h_100_samples.txt",',')[:,mean_or_lower_or_upper]
    protein_deg_rate_data = readdlm("Simulation_data_TX_TL_mRNA_prot_conc/protein_deg_rate_at_$(timepoint)_h_100_samples.txt",',')[1,mean_or_lower_or_upper]
    mRNA_deg_rate = log(2)/0.290833 #halflife (0.290833 hr ACS SynBio Garamella 2016)

    FB = DF["default_flux_bounds_array"]

    FB[255,2] = 100; #[]-> O2; Oxygen uptake rate in mM/h from Vilkhovoy et al.
    FB[276,2] = 0; #[]-> PYR
    FB[279:281,2] .= 0; #succ, Mal, fum
    FB[268,2] = 0; #etoh
    #Assuming amino acid uptake and synthesis. so, fluxes are (probably in mM/h): uptake = 30; synthesis = 100; secretion = 0;
    FB[282:2:320,2] .= 30; #AA UPTAKE
    FB[108:124,2] .= 0.0; #AA Degradation rxns.


    #==============================================TXTL=====================================================#
    #values from txtl ODE solution. Files: Balances_using_Varner_my_own.jl and run_Balances_using_Varner_my_own.jl

    #S28
    FB[175,:] .= TX_data[1]; #transcriptional initiation #TX rate
    FB[177,:] .= TX_data[1];#mRNA_degradation #TX rate
    FB[184,2] = TL_data[1]; #translation initiation #TL rate


    #CISSRA
    FB[178,:] .=  TX_data[2]; #transcriptional initiation #TX rate
    FB[180,:] .=  TX_data[2];  #mRNA_degradation #TX rate
    FB[206,2] =  TL_data[2];   #translation initiation #TL rate
    FB[322,:] .= protein_deg_rate_data*protein_data[2];#ADD CLPXP Degradation

    #deGFP_ssrA
    FB[181,:] .= TX_data[3]; #transcriptional initiation #TX rate
    FB[183,:] .=  TX_data[3]; #mRNA_degradation #TX rate
    FB[228,2] = TL_data[3]; #translation initiation #TL rate
    FB[323,:] .= protein_deg_rate_data*protein_data[3]; #ADD CLPXP Degradation

    #change bounds of protein exports to be -100 to 100
    FB[252:254,1] .= -100
    #===================================================================================================#


    DF["default_flux_bounds_array"] = FB
    return DF
end
