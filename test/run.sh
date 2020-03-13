#!/usr/bin/env bash

cd ../build/lib/Transforms/PA1
make
cd ../../../../test
../build/bin/clang -S -emit-llvm test.c -o test.ll -Xclang -disable-O0-optnone
../build/bin/opt -S -instnamer -mem2reg test.ll -o opt.ll
# clang -S -emit-llvm test.c -O0 -o test.ll
../build/bin/opt -load ../build/lib/FunctionInfoPass.dylib -function-liveness < ../test/opt.ll > /dev/null