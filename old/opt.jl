using BlackBoxOptim
using DelimitedFiles
using Random

const Seed = parse(Int, ARGS[1])
const D = parse(Int, ARGS[2])
const FIBERS = 10
Random.seed!(Seed)

run(`rm -rf results/borg`)
run(`mkdir results/borg`)
run(`rm -rf results/history/genomes-D$D-Seed-$Seed`)
run(`mkdir results/history/genomes-D$D-Seed-$Seed`)
open("results/history/D$D-Seed-$Seed.csv", "w") do file
    write(file, "steps, F\n")
end

function normalize(x, minx, maxx, a, b)
    return (b - a)*((x - minx)/(maxx - minx)) + a
end

# Bresenham's line algorithm: https://en.wikipedia.org/wiki/Bresenham's_line_algorithm
function rasterize(_x0, _y0, _x1, _y1, z)
    x0 = Int(round(normalize(_x0, 0.0, 1.0, 1, 50)))
    y0 = Int(round(normalize(_y0, 0.0, 1.0, 1, 50)))
    x1 = Int(round(normalize(_x1, 0.0, 1.0, 1, 50)))
    y1 = Int(round(normalize(_y1, 0.0, 1.0, 1, 50)))
    points = []
    dx = abs(x1 - x0)
    sx = x0 < x1 ? 1 : -1
    dy = -abs(y1 - y0)
    sy = y0 < y1 ? 1 : -1
    err = dx+dy
    while true
        points = vcat(points, [x0, y0, z]) #plot(x0, y0);
        if x0 == x1 && y0 == y1
            break
        end
        e2 = 2*err
        if e2 >= dy
            err += dy
            x0 += sx
        end
        if e2 <= dx
            err += dx
            y0 += sy
        end
    end
    return points
end

function submit_fitness_job(params)
    r1 = rand(1:1000)
    r2 = rand(1:1000)
    points = []
    for i in 1:4:length(params)
        if i <= div(length(params), 2)
            p = rasterize(params[i], params[i+1], params[i+2], params[i+3], 0)
            points = vcat(points, p)
        else
            p = rasterize(params[i], params[i+1], params[i+2], params[i+3], -2)
            points = vcat(points, p)
        end
    end
    open("results/borg/$r1-$r2.csv", "w") do file
        write(file, "$(div(length(points), 3)) ")
        for p in points
            write(file, "$p ")
        end
    end
    run(`./membrane.exe results/borg/$r1-$r2.csv target/d$D.csv.res`)
    F = readdlm("results/borg/$r1-$r2.csv.res")
    run(`rm results/borg/$r1-$r2.csv`)
    run(`rm results/borg/$r1-$r2.csv.res`)
    return 100*F[1]
end

steps = 0
function callback(oc)
    global steps
    open("results/history/D$D-Seed-$Seed.csv", "a") do file
        F = best_fitness(oc)
        write(file, "$(steps), $(F)\n")
    end
    params = best_candidate(oc)
    points = []
    for i in 1:4:length(params)
        if i <= div(length(params), 2)
            p = rasterize(params[i], params[i+1], params[i+2], params[i+3], 0)
            points = vcat(points, p)
        else
            p = rasterize(params[i], params[i+1], params[i+2], params[i+3], -2)
            points = vcat(points, p)
        end
    end
    open("results/best/D$D-Seed-$Seed.csv", "w") do file
        write(file, "$(div(length(points), 3)) ")
        for p in points
            write(file, "$p ")
        end
    end
    open("results/history/genomes-D$D-Seed-$Seed/$steps.csv", "w") do file
        write(file, "$(div(length(points), 3)) ")
        for p in points
            write(file, "$p ")
        end
    end
    steps += 1
end

res = bboptimize(submit_fitness_job;
    SearchRange=(0.0, 1.0), NumDimensions=FIBERS*4,
    Method=:dxnes, MaxSteps=200, PopulationSize=20,
    CallbackFunction=callback, CallbackInterval=0.0)

params = best_candidate(res)
points = []
for i in 1:4:length(params)
    global points
    if i <= div(length(params), 2)
        p = rasterize(params[i], params[i+1], params[i+2], params[i+3], 0)
        points = vcat(points, p)
    else
        p = rasterize(params[i], params[i+1], params[i+2], params[i+3], -2)
        points = vcat(points, p)
    end
end
open("results/best/D$D-Seed-$Seed.csv", "w") do file
    write(file, "$(div(length(points), 3)) ")
    for p in points
        write(file, "$p ")
    end
end