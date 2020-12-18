/usr/local/opt/llvm/bin/clang++ membrane.cpp -o membrane.exe \
-std=c++17 -O3 -DUSE_OMP=1 \
-I./include -L./lib -lvoxelyze \
-I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp