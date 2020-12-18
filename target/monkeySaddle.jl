using DelimitedFiles

function normalize(x, minx, maxx, a, b)
    return (b - a)*((x - minx)/(maxx - minx)) + a
end

xs = LinRange(-25, 25, 50)
ys = LinRange(-25, 25, 50)
zs = [x^3 - 3*x*y^2 for x in xs, y in ys]

d1 = [readdlm("d1.csv.res")[1:end-1]...];
a = minimum(d1); b = maximum(d1);

for idx in CartesianIndices(zs)
	zs[idx] = normalize(zs[idx], minimum(zs), maximum(zs), a*2, b*2)
end

open("d2.csv.res", "w") do file
	i = 1
	for x in 1:50
		for y in 1:50
			if d1[i] == 0
				write(file, "0 ")
			else
				write(file, "$(zs[x, y]) ")
			end
			i+=1
		end
	end
end