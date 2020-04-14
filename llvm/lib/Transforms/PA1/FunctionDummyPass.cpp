
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include <iostream>

using namespace llvm;

namespace {
class FunctionInfo : public FunctionPass {
public:
  static char ID;
  FunctionInfo() : FunctionPass(ID) {}
  ~FunctionInfo() {}

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

char FunctionInfo::ID = 0;
static RegisterPass<FunctionInfo>
    X("function-dummy", "CSE521: Function Information", false, false);