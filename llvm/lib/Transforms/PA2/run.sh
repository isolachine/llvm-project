#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
        EXT="dylib"
else
        EXT="so"
fi

LEVEL="../../../.."

# Build the loop analysis pass
cd $LEVEL/build/lib/Transforms/PA2
make
cd -

# Compile the source code into IR
# $LEVEL/build/bin/clang -S -emit-llvm test/test.c -o test/test.ll

# Run the function pass on the test file
$LEVEL/build/bin/opt -load $LEVEL/build/lib/LoopAnalysisPass.$EXT -loop-analysis < test/MatrixmultiplicationTest.ll > /dev/null
echo "========="
$LEVEL/build/bin/opt -load $LEVEL/build/lib/LoopAnalysisPass.$EXT -loop-analysis < test/QuicksortTest.ll > /dev/null