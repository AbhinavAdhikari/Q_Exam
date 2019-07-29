#####################
#####################
include("DataDictionary.jl")
include("FluxDriver.jl")
include("bounds.jl")
include("Experimental_constraints.jl")
using DelimitedFiles
using GLPK
#####################
#####################

timepoint_for_experimental_constraints = 1 #timepoint=1,2,3,4 or 5 corresponding to 1h,2h,4h,8h,16h. It is used to pick what time point I want to specify for my experimental flux. 2 would mean that I constrain the problem using metabolic and amino acid fluxes calculated at the 2 hour point.
timepoint_for_simulation = 1 #0.002,0.05,0.1,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8,10,16.
mean_lower_or_upper = 2 #1 or 2 or 3. Mean or (mean-sd) or (mean+sd)

# load the data dictionary
data_dictionary = DataDictionary(0,0,0)

#Set objective reaction
data_dictionary["objective_coefficient_array"][252:254] .= -1;


#Change species bounds array for maltodextrin so that its input flux is upto 30 mM/h
data_dictionary["species_bounds_array"][97,1] = -30 #mM/h #M_maltodextrin6_c

#Change bounds on TX, TL and other equations like oxygen exchange, etc.
data_dictionary=Bounds(data_dictionary,timepoint_for_simulation,mean_lower_or_upper)

#apply experimental constrints (Amino acid and metabolic fluxes)
data_dictionary=Experimental_constraints(data_dictionary,timepoint_for_experimental_constraints)

#Solve the lp problem
(objective_value, flux_array, dual_array, uptake_array, exit_flag) = FluxDriver(data_dictionary)

