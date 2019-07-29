# using Polynomials
using DelimitedFiles
using PyCall
@pyimport numpy as np
# using Calculus
# using Plots
using SmoothingSplines
using RDatasets


data_amino_acids = readdlm("AA_data_incl_0h.csv",',',header=false)
data_time = [1.0;2.0;4.0;8.0;16.0]
data_name_of_aa = data_amino_acids[2:end,1]
t_vec = collect(1.0:0.01:16.0)

#===============Interpolate Concentration values==========#
#np.interp(time points where you want interpolation, given time vector, given data)

#initialize array
sim_aa = Array{Any}(undef,19,1); #Each row is an amino acid
for i in 1:length(data_name_of_aa) #Each row contains interpolated data for an amino acid
    sim_aa[i] = np.interp(t_vec,data_time,data_amino_acids[i+1,3:end])
end

#Use splines to smoothen the curve
for i in 1:length(data_name_of_aa) #Each row contains interpolated data for an amino acid
    sim_aa[i] = np.interp(t_vec,data_time,data_amino_acids[i+1,3:end])
end

#store spline data in predicted_spline. Each row is an array with the predicted spline data for an amino acid.
spline_data = Array{Any}(undef,19,1);
predicted_spline = Array{Any}(undef,19,1);
for i in 1:length(data_name_of_aa)
    spline_data[i] = fit(SmoothingSpline,t_vec,sim_aa[i],2.0)
    predicted_spline[i] = SmoothingSplines.predict(spline_data[i])
end

#Plot the predicted spline data vs experimental data.
row = 5;
col = 4;
using PyPlot
# for i in 1:length(data_name_of_aa)
figure(1)
for i in 1:19
    plt.subplot(row,col,i)
    plt.ylabel(data_name_of_aa[i])
    plt.plot(data_time,data_amino_acids[i+1,3:end],color="black")
    plt.plot(t_vec,predicted_spline[i],color="red")
end
tight_layout()
PyPlot.savefig("aa.png")

#Calculate derivatives
#First find position of time points 1,2,4,8,16 h from t_vec matrix. 1, 101,301,701,1501
deriv_aa= Array{Any}(undef,19,5);
timepoints=[1,101,301,701,1501-2] #1501-2 because using 1501 would update the index to 1503, which is not in the data.
for i in 1:19 #loop over the amino acids
    for j in 1:5 #loop over the time (1,2,4,8,16)
        deriv_aa[i,j] = (predicted_spline[i][timepoints[j]+2]-predicted_spline[i][timepoints[j]])/(0.02)
    end
end

#export flux data
writedlm("calculated_aa_flux.txt",deriv_aa,',')
