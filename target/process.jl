using DelimitedFiles

file = open("uninflated.csv", "r")
base_arr = readdlm(file)

file = open("saddle-0.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("saddle-target-0.csv",  arr, ' ')

file = open("saddle-1.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("saddle-target-1.csv",  arr, ' ')

file = open("saddle-2.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("saddle-target-2.csv",  arr, ' ')

file = open("saddle-3.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("saddle-target-3.csv",  arr, ' ')

file = open("monkey-0.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("monkey-target-0.csv",  arr, ' ')

file = open("monkey-1.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("monkey-target-1.csv",  arr, ' ')

file = open("monkey-2.csv", "r")
arr = readdlm(file)
arr = abs.(arr .- base_arr)
writedlm("monkey-target-2.csv",  arr, ' ')