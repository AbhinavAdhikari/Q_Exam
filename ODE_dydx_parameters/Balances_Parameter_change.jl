function Balances_Parameter_change(t,x,parameters_rnd)
    global TX,TL

    #Experimental parameters
    gene_length = Array{Float64}([
        720  ;   #S28
        744  ;   #CISSRA
        711  ;   #deGFP_ssrA
    ]);

    protein_length = Array{Float64}([
        240 ;   #S28
        248 ;   #CISSRA
        237 ;   #deGFP_ssrA

    ]);

    gene_concentration = Array{Float64}([ #uM Plasmid dosage in uM.
        1/1000  ;   #S28
        1/1000 ;   #CISSRA
        8/1000  ;   #deGFP_ssrA
    ]);

    #define p70 and other promoter variables (from Vilklhovoy et al 2018)
    S_70 = 35 #nM S70 concentration
    K_S70 = 130 #nM dissociation constant
    K_S28 = 130 #nM. Assumed same dissociation constant as K_S70
    n = 1
    W_1 = 0.014
    W_2 = 10
    # W_repressor = 1000;


    #control function for P70,P19,P28
    F_P70=(S_70^n/(K_S70^n+S_70^n))   #P70 promoter
    F_P28=((x[4]*1e6)^n/(K_S28^n+(x[4]*1e6)^n))
    F_CISSRA=((x[5]*1e6)^2/((K_S70)^2+(x[5]*1e6)^2))

    u_P70 = (W_1 + W_2*F_P70)/(1+W_1+W_2*F_P70+parameters_rnd[3]*F_CISSRA)   #P70 promoter
    u_P28 = (W_1 + W_2*F_P28)/(1+W_1+W_2*F_P28) #P28 promoter.  assumed same form as P70

    #Promoter Control terms
    u_i = Array{Float64}([
        u_P70 ; #S28
        u_P28 ; #CISSRA
        u_P70 ; #deGFP_ssrA
    ]);


    #TX TL saturation constants from CHEME7770 prelim and Vilkhovoy.
    # elongation_slope = 0.3# μM "McClure 1980= 0.3"
    # Ksat_X_P70 = 0.3/7.8   # μM #elongation_slope
    # Ksat_L_P70 = 57/4.5 # Prelim = 57.
    # Ksat_X_P28 = 0.3
    # Ksat_L_P28 = 57

    #Saturation constants for the different promoters
    Ksat_X = Array{Float64}([ #μM
    		parameters_rnd[4] ; #S28
    		parameters_rnd[6] ; #CI_ssrA
    		parameters_rnd[4] ; #deGFP_ssrA
    ]);

    #TL Saturation constants for the different promoters
    Ksat_L = Array{Float64}([ #μM
    		parameters_rnd[5] ; #S28
    		parameters_rnd[7] ; #CI_ssrA
    		parameters_rnd[5] ; #deGFP_ssrA
    ]);


    tau_X = Array{Float64}([ #μM
    		parameters_rnd[8] ; #S28
    		parameters_rnd[10] ; #CI_ssrA
    		parameters_rnd[8] ; #deGFP_ssrA
    ]);
    tau_L = Array{Float64}([ #μM
    		parameters_rnd[9] ; #S28
    		parameters_rnd[11] ; #CI_ssrA
    		parameters_rnd[9] ; #deGFP_ssrA
    ]);


    #To calculate TX rate constant of elongation k_e_X
    characteristic_gene_length = 1000 #nt

    length_ratio_X = Array{Float64}([ #dimensionless
    		characteristic_gene_length/gene_length[1] ;
    		characteristic_gene_length/gene_length[2] ;
    		characteristic_gene_length/gene_length[3] ;
    ]);

    max_transcription_rate = 25;    # >5 NT/s (ACS SynBio Garamella 2016)
    elongation_rate_constant_average_X = 3600*(max_transcription_rate/characteristic_gene_length) # per hour

    k_e_X = Array{Float64}([ #per hour
    	elongation_rate_constant_average_X*length_ratio_X[1] ;
    	elongation_rate_constant_average_X*length_ratio_X[2] ;
    	elongation_rate_constant_average_X*length_ratio_X[3] ;
    ]);


    #To calculate TL rate constant of elongation k_e_L
    characteristic_protein_length = 330 #aa

    length_ratio_L = Array{Float64}([ #dimensionless
        characteristic_protein_length/protein_length[1] ;
        characteristic_protein_length/protein_length[2] ;
        characteristic_protein_length/protein_length[3] ;
    ]);

    max_translation_rate = 1.5; #>1 (ACS SynBio Garamella 2016) & 1.5 AA/sec (Underwood, Swartz, Puglisi 2005 Biotech Bioeng)
    elongation_rate_constant_average_L = 3600*(max_translation_rate/characteristic_protein_length) #per hour

    k_e_L = Array{Float64}([ #per hour
    	elongation_rate_constant_average_L*length_ratio_L[1] ;
    	elongation_rate_constant_average_L*length_ratio_L[2] ;
    	elongation_rate_constant_average_L*length_ratio_L[3] ;
    ]);

    #Final TXTL expressions
    R_XT = parameters_rnd[12]; #uM RNAP concentration #60-75nM (ACS SynBio Garamella 2016 Appendix)
    TX = similar(gene_concentration)
    for i in 1:length(gene_concentration)
        TX[i] = (u_i[i]*(k_e_X[i]*parameters_rnd[12]*(gene_concentration[i]/(tau_X[i]*Ksat_X[i] + (tau_X[i]+1)*gene_concentration[i]))))/1000 #mM per hour
    end

    R_LT = parameters_rnd[13]; #uM #Ribosome concentration #0.0016mM with 72% MaxActive (Underwood, Swartz, Puglisi 2005 Biotech Bioeng) & <0.0023mM (ACS SynBio Garamella 2016)
    polysome_gain = 10;
    TL = similar(gene_concentration)
    for i in 1:length(gene_concentration)
        TL[i] = (k_e_L[i]*parameters_rnd[13]*polysome_gain*((x[i]*1000)/(tau_L[i]*Ksat_L[i] + (tau_L[i]+1)*(x[i]*1000))))/1000 #mM per hour
    end

    # calculate the degradation constants for mRNA and protein -
    mRNA_half_life = 0.290833 #h (0.290833 hr ACS SynBio Garamella 2016)
    kdX = log(2)/mRNA_half_life #per hour

    protein_half_life =70#h"
    kdL = log(2)/protein_half_life #per hour

    protein_half_life_degrad_tag = parameters_rnd[14] #h #source: Niederholtmeyer 2015 Table 2.
    kdL_tagged = log(2)/protein_half_life_degrad_tag #per hour

    #Setup Mass Balances
    dxdt = similar(x)
    dxdt[1]  = TX[1] - x[1]*kdX #S28 mRNA in mM/h
    dxdt[2]  = TX[2] - x[2]*kdX #CISSRA mRNA in mM/h
    dxdt[3]  = TX[3] - x[3]*kdX #deGFP_ssrA mRNA in mM/h
    dxdt[4]  = TL[1] - x[4]*kdL #S28 protein in mM/h
    dxdt[5]  = TL[2] - x[5]*kdL_tagged #CISSRA protein in mM/h
    dxdt[6]  = TL[3] - x[6]*kdL_tagged #deGFP_ssrA protein in mM/h
    return dxdt

end
