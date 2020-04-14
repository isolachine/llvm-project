
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

  bool doInitialization(Module &M) override { return false; }

  bool runOnFunction(Function &F) override {
    errs() << "Function: " << F.getName() << "\n";
    errs() << "\tNum of arguments: " << F.arg_size() << "\n";

    errs() << "\tCall site count: " << F.getNumUses() << "\n";
    for (auto U : F.users()) {
      if (auto I = dyn_cast<Instruction>(U)) {
        errs() << "\t";
        I->print(errs());
        errs() << " in BB [" << I->getParent()->getName() << "] of function ["
               << I->getParent()->getParent()->getName() << "]\n";
      }
    }

    errs() << "\tBasic blocks: " << F.getBasicBlockList().size() << "\n";
    errs() << "\tInstructions: " << F.getInstructionCount() << "\n";

    return false;
  }
};
} // namespace

char FunctionInfo::ID = 0;
static RegisterPass<FunctionInfo>
    X("function-info", "CSE521: Function Information", false, false);