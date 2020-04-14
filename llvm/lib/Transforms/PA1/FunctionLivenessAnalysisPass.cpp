
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include <set>

#include <iostream>

using namespace llvm;

namespace {
class FunctionLiveness : public FunctionPass {
private:
  DenseMap<Instruction *, DenseSet<StringRef>> liveIn;
  DenseMap<Instruction *, DenseSet<StringRef>> liveOut;
  DenseMap<Instruction *, DenseSet<StringRef>> UEVar;
  DenseMap<Instruction *, DenseSet<StringRef>> VarKill;
  DenseMap<Instruction *, DenseSet<Instruction *>> SuccInst;
  DenseMap<Instruction *, DenseSet<Instruction *>> PredInst;

public:
  static char ID;
  FunctionLiveness() : FunctionPass(ID) {}
  ~FunctionLiveness() {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  bool doInitialization(Module &M) override { return false; }

  bool runOnFunction(Function &F) override {
    std::vector<Instruction *> Worklist;
    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        // compute the UEVar(I) and VarKill(I) for each instruction
        User::op_iterator OI, OE;
        for (OI = I.op_begin(), OE = I.op_end(); OI != OE; OI++) {
          Value *val = *OI;
          if (isa<Instruction>(val) || isa<Argument>(val)) {
            UEVar[&I].insert(val->getName());
          }
        }
        VarKill[&I].insert(I.getName());

        // generate an instruction level CFG,
        // i.e., treat each instruction as a basic block
        if (BranchInst *BrI = dyn_cast<BranchInst>(&I)) {
          for (BasicBlock *SBB : BrI->successors()) {
            Instruction &I_first = SBB->front();
            if (isa<PHINode>(I_first)) {
              for (BasicBlock::iterator BI = SBB->begin(); BI != SBB->end();
                   BI++) {
                if (!isa<PHINode>(BI)) {
                  break;
                }
                SuccInst[&I].insert(&*BI);
              }
            } else {
              SuccInst[&I].insert(&I_first);
            }
          }
        } else if (PHINode *PI = dyn_cast<PHINode>(&I)) {
          for (Instruction &nonPI : BB) {
            if (!isa<PHINode>(nonPI)) {
              SuccInst[&I].insert(&nonPI);
              break;
            }
          }
        } else {
          if (I.getNextNode())
            SuccInst[&I].insert(I.getNextNode());
        }
        Worklist.push_back(&I);
      }
    }

    // build the backwards version of the instruction level CFG
    for (DenseMap<Instruction *, DenseSet<Instruction *>>::iterator iter =
             SuccInst.begin();
         iter != SuccInst.end(); iter++) {
      for (Instruction *I : iter->second) {
        PredInst[I].insert(iter->first);
      }
    }

    while (!Worklist.empty()) {
      Instruction *I = Worklist.back();
      Worklist.pop_back();
      liveOut[I] = DenseSet<StringRef>();

      DenseSet<StringRef> omitSet;
      for (Instruction *SI : SuccInst[I]) {
        liveOut[I] = setUnion(liveOut[I], liveIn[SI]);
        if (!isa<PHINode>(*SI)) {
        } else {
          omitSet.insert(SI->getName());
          PHINode *PHII = dyn_cast<PHINode>(SI);
          unsigned int value_count = PHII->getNumIncomingValues();
          for (unsigned int i = 0; i < value_count; i++) {
            if (PHII->getIncomingBlock(i) != I->getParent()) {
              omitSet.insert(PHII->getIncomingValue(i)->getName());
            }
          }
        }
      }
      liveOut[I] = setDiff(liveOut[I], omitSet);
      DenseSet<StringRef> tmpLiveIn = liveIn[I];
      liveIn[I] = setUnion(setDiff(liveOut[I], VarKill[I]), UEVar[I]);
      if (setDiff(liveIn[I], tmpLiveIn).size() != 0 ||
          setDiff(tmpLiveIn, liveIn[I]).size() != 0) {
        for (Instruction *pred : PredInst[I]) {
          Worklist.push_back(pred);
        }
      }
    }

    errs() << "Function: " << F.getName() << "\n";
    for (BasicBlock &BB : F) {
      errs() << BB.getName() << ":\n";
      for (Instruction &I : BB) {
        if (!isa<PHINode>(I)) {
          printSet(liveIn[&I]);
        }
        I.dump();
      }
      printSet(liveOut[&BB.back()]);
      errs() << "\n";
    }
    return false;
  }

  void printSet(DenseSet<StringRef> set) {
    unsigned int count = 0;
    errs() << "\t{";
    for (StringRef str : set) {
      count++;
      errs() << str;
      if (count != set.size())
        errs() << ",";
    }
    errs() << "}\n";
  }

  DenseSet<StringRef> setUnion(DenseSet<StringRef> a, DenseSet<StringRef> b) {
    for (StringRef str : b) {
      a.insert(str);
    }
    return a;
  }

  DenseSet<StringRef> setDiff(DenseSet<StringRef> a, DenseSet<StringRef> b) {
    for (StringRef str : b) {
      a.erase(str);
    }
    return a;
  }
};
} // namespace

char FunctionLiveness::ID = 0;
static RegisterPass<FunctionLiveness>
    X("function-liveness", "CSE521: Function Information", false, false);