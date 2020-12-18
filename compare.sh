/usr/local/opt/llvm/bin/clang++ compare.cpp -o compare.exe \
-std=c++17 -O3 -DUSE_OMP=1 \
-I./include -L./lib -lvoxelyze \
-I/usr/local/opt/llvm/include -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -fopenmp
./compare.exe