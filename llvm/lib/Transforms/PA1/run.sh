#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
        EXT="dylib"
else
        EXT="so"
fi

LEVEL="../../../.."

# Build the function passes
cd $LEVEL/build/lib/Transforms/PA1
make
cd -

# Compile the source code into IR
$LEVEL/build/bin/clang -S -emit-llvm test/test.c -Xclang -disable-O0-optnone -o /dev/stdout | $LEVEL/build/bin/opt -S -instnamer -mem2reg -o test/test.ll


echo
echo -------- Task 2: Dummy Function Pass --------
$LEVEL/build/bin/opt -load $LEVEL/build/lib/FunctionInfoPass.$EXT -function-dummy < test/test.ll > /dev/null # Task 2
echo
echo -------- Task 3: Printing Function Information --------
$LEVEL/build/bin/opt -load $LEVEL/build/lib/FunctionInfoPass.$EXT -function-info < test/test.ll > /dev/null # Task 3
echo
echo -------- Task 4: Liveness Analysis --------
$LEVEL/build/bin/opt -load $LEVEL/build/lib/FunctionInfoPass.$EXT -function-liveness < test/test.ll > /dev/null # Task 4