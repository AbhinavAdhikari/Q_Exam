# For reaction list, please refer to Debug.txt

# include("/home/abhi/Documents/Research/Q Exam/CODE/txtl_balances/Balances_for_FBA.jl");
#import calculated TXTL rates

#Species Index for TXTL rates:
# 1 S28
# 2 CISSRA
# 3 deGFP_ssrA

# ----------------------------------------------------------------------------------- #
function Experimental_constraints(DF,time_code) #timepoint = 1(1h),2(2h),3(4h),4(8h),5(16h) corresponds to the column number for fluxes

    SBA = DF["species_bounds_array"]

    metab_flux_exp = readdlm("calculated_metabolite_flux.txt",',')[:,time_code]
    aa_flux_exp = readdlm("calculated_aa_flux.txt",',')[:,time_code]
    metab_sp_index = Int64.(readdlm("metab_species_index.txt"))
    aa_sp_index = Int64.(readdlm("aa_species_index.txt"))

    removed = [3,16,19,22,28,30]
    remaining = [1,2,4:15...,17,18,20,21,23:27...,29,31:41...]
    metab_flux_exp_edited = metab_flux_exp[remaining]
    metab_sp_index_edited = metab_sp_index[remaining]

    #change amino acids species_bounds_array
    for i in 1:length(aa_sp_index)
        if aa_flux_exp[i] > 0
            lb = 0.0
            ub = aa_flux_exp[i]
        elseif aa_flux_exp[i] < 0
            lb = aa_flux_exp[i]
            ub = 0.0
        end
        if lb == 0.0
            SBA[aa_sp_index[i],2] = ub
        elseif ub == 0.0
            SBA[aa_sp_index[i],1] = lb
        end
    end

    #change metabolites species bounds array
    for i in 1:length(metab_sp_index_edited)
        if metab_flux_exp_edited[i] > 0
            lb = 0.0
            ub = metab_flux_exp_edited[i]
        elseif metab_flux_exp_edited[i] < 0
            lb = metab_flux_exp_edited[i]
            ub = 0.0
        end
        if lb == 0.0
            SBA[metab_sp_index_edited[i],2] = ub
        elseif ub == 0.0
            SBA[metab_sp_index_edited[i],1] = lb
        end
    end

    DF["species_bounds_array"] = SBA
    return DF
end
