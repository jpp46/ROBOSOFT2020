using Plots
using DelimitedFiles
using Statistics
gr()

x = collect(0:119)
arr = Float64.(readdlm("../history/Bezier-D1-Seed-3-Best.csv", ',', Any, '\n')[2:end, :])[:, 2]
for i in 1:2
	arr = hcat(arr, Float64.(readdlm("../history/Bezier-D1-Seed-$i-Best.csv", ',', Any, '\n')[2:end, :])[:, 2])
end
avg = mean(arr, dims=2)[:].*100
stddev = std(arr, dims=2)[:].*100
plot(x, avg, ribbon=stddev,
	title="Evolutionary Progress", label="Saddle")

arr = Float64.(readdlm("../history/Bezier-D2-Seed-0-Best.csv", ',', Any, '\n')[2:end, :])[:, 2]
for i in 1:2
	arr = hcat(arr, Float64.(readdlm("../history/Bezier-D2-Seed-$i-Best.csv", ',', Any, '\n')[2:end, :])[:, 2])
end
avg = mean(arr, dims=2)[:].*100
stddev = std(arr, dims=2)[:].*100
plot!(x, avg, ribbon=stddev, ylims=(0, 100),
	title="Evolutionary Progress", xlabel="Generations", ylabel="% Error", label="Monkey Saddle", legend=true)
savefig("Plot.png")