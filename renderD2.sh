/usr/local/opt/llvm/bin/clang++ render.cpp -o render.exe \
-std=c++17 -O3 -DUSE_OMP=1 \
-I./include -L./lib -lvoxelyze \
-I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp
./render.exe results/best/Bezier-D2-Seed-0.csv target/d2.csv.res
julia render.jl 2 0
./render.exe results/best/Bezier-D2-Seed-1.csv target/d2.csv.res
julia render.jl 2 1
./render.exe results/best/Bezier-D2-Seed-2.csv target/d2.csv.res
julia render.jl 2 2

./render.exe results/best/Bezier-D2-Seed-3.csv target/d2.csv.res
julia render.jl 2 3
./render.exe results/best/Bezier-D2-Seed-4.csv target/d2.csv.res
julia render.jl 2 4
./render.exe results/best/Bezier-D2-Seed-5.csv target/d2.csv.res
julia render.jl 2 5
./render.exe results/best/Bezier-D2-Seed-6.csv target/d2.csv.res
julia render.jl 2 6
./render.exe results/best/Bezier-D2-Seed-7.csv target/d2.csv.res
julia render.jl 2 7