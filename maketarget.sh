/usr/local/opt/llvm/bin/clang++ maketarget.cpp -o maketarget.exe \
-std=c++17 -O3 -DUSE_OMP=1 \
-I./include -L./lib -lvoxelyze \
-I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp
./maketarget.exe target/d1.csv
julia render.jl 1