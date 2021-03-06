/usr/local/opt/llvm/bin/clang++ render.cpp -o render.exe \
-std=c++17 -O3 -DUSE_OMP=1 \
-I./include -L./lib -lvoxelyze \
-I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp
./render.exe results/best/Bezier-D1-Seed-0.csv target/d1.csv.res
julia render.jl 1 0
./render.exe results/best/Bezier-D1-Seed-1.csv target/d1.csv.res
julia render.jl 1 1
./render.exe results/best/Bezier-D1-Seed-2.csv target/d1.csv.res
julia render.jl 1 2
./render.exe results/best/Bezier-D1-Seed-3.csv target/d1.csv.res
julia render.jl 1 3
./render.exe results/best/Bezier-D1-Seed-4.csv target/d1.csv.res
julia render.jl 1 4