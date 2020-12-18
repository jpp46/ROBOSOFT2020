using Makie
using FileIO
using Colors
using GeometryBasics
using DelimitedFiles

const D = parse(Int, ARGS[1])
const Seed = parse(Int, ARGS[2])

z_offset = (20*0.0028)
y_offset = (30*0.0028)
x_offset = (80*0.0028)

function eyepos(cord)
    sz = size(cord)[1]
    x_avg = sum(cord[:, 1])/sz
    y_avg = sum(cord[:, 2])/sz
    z_avg = sum(cord[:, 3])/sz
    return Vec3f0(x_offset, -y_offset, z_offset)
end

function eyeposTop(cord)
    sz = size(cord)[1]
    x_avg = sum(cord[:, 1])/sz
    y_avg = sum(cord[:, 2])/sz
    z_avg = sum(cord[:, 3])/sz
    return Vec3f0((25*0.0028), (25*0.0028), (70*0.0028))
end

function eyeposBot(cord)
    sz = size(cord)[1]
    x_avg = sum(cord[:, 1])/sz
    y_avg = sum(cord[:, 2])/sz
    z_avg = sum(cord[:, 3])/sz
    return Vec3f0((25*0.0028), (25*0.0028), -(70*0.0028))
end

function lookat(cord)
    sz = size(cord)[1]
    x_avg = sum(cord[:, 1])/sz
    y_avg = sum(cord[:, 2])/sz
    z_avg = sum(cord[:, 3])/sz
    return Vec3f0(x_avg, y_avg, z_avg)
end

function get_mesh(n)
    coordinates = readdlm("viz/$n.cor", Float32)
    connectivity = readdlm("viz/$n.con", Int32)
    clr = readdlm("viz/$n.clr", Float64)
    colors = [RGBA(clr[i, :]...) for i in 1:size(clr)[1]]
    vertices = [
        Point((coordinates[r, 1], coordinates[r, 2], coordinates[r, 3])) 
        for r in 1:size(coordinates)[1]
    ]
    faces = [
        NgonFace((connectivity[r, 1], connectivity[r, 2], connectivity[r, 3])) 
        for r in 1:size(connectivity)[1]
    ]
    return coordinates, vertices, faces, colors
end

files = readdir("./viz")
n = maximum(map(f -> parse(Int, f[1:end-4]), files))





scene = Scene(backgroundcolor=:black, show_axis=false, center=false)
xy, vertices, faces, colors = get_mesh(0)
m = GeometryBasics.Mesh(vertices, faces)
wireframe!(scene, m, color=RGBA(0.4, 1.0, 0.4, 0.5))
mesh!(scene, m, color=colors)

update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("target/D$(D)Top.png", scene)

update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("target/D$(D)Bot.png", scene)



scene = Scene(backgroundcolor=:black, show_axis=false, center=false)
xy, vertices, faces, colors = get_mesh(1)
m = GeometryBasics.Mesh(vertices, faces)
wireframe!(scene, m, color=RGBA(0.4, 1.0, 0.4, 0.5))
mesh!(scene, m, color=colors)

update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("target/D$(D).png", scene)





scene = Scene(backgroundcolor=:black, show_axis=false, center=false)
xy, vertices, faces, colors = get_mesh(2)
m = GeometryBasics.Mesh(vertices, faces)
wireframe!(scene, m, color=RGBA(0.4, 1.0, 0.4, 0.5))
mesh!(scene, m, color=colors)

update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("resTop-D$D-Seed-$Seed.png", scene)

update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("resBot-D$D-Seed-$Seed.png", scene)



scene = Scene(backgroundcolor=:black, show_axis=false, center=false)
xy, vertices, faces, colors = get_mesh(3)
m = GeometryBasics.Mesh(vertices, faces)
wireframe!(scene, m, color=RGBA(0.4, 1.0, 0.4, 0.5))
mesh!(scene, m, color=colors)


update_cam!(scene, eyepos(xy), lookat(xy))
Makie.save("res-D$D-Seed-$Seed.png", scene)

#=m = Node(msh)
coordinates = lift(m -> m[1], m)
connectivity = lift(m -> m[2], m)
colors = lift(m -> m[3], m)
mesh!(scene, coordinates, connectivity, color=colors)
update_cam!(scene, eyepos(msh[1]), lookat(msh[1]))
seye = eyepos(msh[1])

record(scene, "video.mp4", 0:n; framerate=2) do i
    msh = get_mesh(i)
    m[] = msh
    update_cam!(scene, eyepos(msh[1]), lookat(msh[1]))
end=#