
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include <iostream>

using namespace llvm;

namespace {
class FunctionDummy : public FunctionPass {
public:
  static char ID;
  FunctionDummy() : FunctionPass(ID) {}
  ~FunctionDummy() {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  bool doInitialization(Module &M) override {
    errs() << "CSE521 Function Information Pass\n";
    return false;
  }

  bool runOnFunction(Function &F) override { return false; }
};
} // namespace

char FunctionDummy::ID = 0;
static RegisterPass<FunctionDummy>
    X("function-dummy", "CSE521: Function Information", false, false);