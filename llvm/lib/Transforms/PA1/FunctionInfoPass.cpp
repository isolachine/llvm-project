
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

  // We don't modify the program, so we preserve all analyses
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  // Do some initialization
  bool doInitialization(Module &M) override {
    errs() << "CSE521 Function Information Pass\n"; // TODO: remove this.
    // outs() << "Name,\tArgs,\tCalls,\tBlocks,\tInsns\n";
    return false;
  }

  // Print output for each function
  bool runOnFunction(Function &F) override {
    // outs() << "name" << ",\t" << "args" << ",\t" << "calls" << ",\t" << "bbs"
    // << ",\t" << "insts" << "\n";
    errs() << "Function: " << F.getName() << "\n";
    errs() << "\tNum of arguments: " << F.arg_size() << "\n";
    errs() << "\tCall site: " << F.arg_size() << "\n";
    errs() << "\tBasic blocks: " << F.getBasicBlockList().size() << "\n";
    errs() << "\tInstructions: " << F.getInstructionCount() << "\n";

    unsigned int bbCnt = 0;
    unsigned int instCnt = 0;
    for (BasicBlock &bb : F) {
      bbCnt++;
      for (Instruction &i : bb) {
        instCnt++;
        if (CallInst *callInst = dyn_cast<CallInst>(&i)) {
          if (Function *calledFunction = callInst->getCalledFunction()) {
            if (calledFunction->getName().startswith("llvm.dbg.declare")) {
            }
          }
        }
      }
    }
    errs() << "\tBasic blocks: " << bbCnt << "\n";
    errs() << "\tInstructions: " << instCnt << "\n";

    return false;
  }
};
} // namespace

// LLVM uses the address of this static member to identify the pass, so the
// initialization value is unimportant.
char FunctionInfo::ID = 0;
static RegisterPass<FunctionInfo>
    X("function-info", "CSE521: Function Information", false, false);

namespace {
class FunctionLiveness : public FunctionPass {
private:
  DenseMap<Instruction *, DenseSet<StringRef>> liveIn;
  DenseMap<Instruction *, DenseSet<StringRef>> liveOut;
  DenseMap<Instruction *, DenseSet<StringRef>> UEVar;
  DenseMap<Instruction *, DenseSet<StringRef>> VarKill;
  DenseMap<Instruction *, DenseSet<Instruction *>> SuccInst;
  DenseMap<Instruction *, DenseSet<Instruction *>> PredInst;
  DenseMap<BasicBlock *, DenseSet<StringRef>> liveInB;
  DenseMap<BasicBlock *, DenseSet<StringRef>> liveOutB;

public:
  static char ID;
  FunctionLiveness() : FunctionPass(ID) {}
  ~FunctionLiveness() {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  bool doInitialization(Module &M) override { return false; }

  bool runOnFunction(Function &F) override {

    for (BasicBlock &BB : F) {
      // errs() << "  " << BB.getName() << ":\n";
      for (Instruction &I : BB) {
        // compute the UEVar(I) and VarKill(I)
        User::op_iterator OI, OE;
        for (OI = I.op_begin(), OE = I.op_end(); OI != OE; OI++) {
          Value *val = *OI;
          if (isa<Instruction>(val) || isa<Argument>(val)) {
            UEVar[&I].insert(val->getName());
          }
        }
        VarKill[&I].insert(I.getName());
        // I.dump();
        // printSet(UEVar[&I]);
        // printSet(VarKill[&I]);
      }
    }
    std::vector<Instruction *> Worklist;
    // errs() << "=======--------=======\n";
    for (BasicBlock &BB : F) {
      for (Instruction &I : BB) {
        // generate a instruction level CFG
        // errs() << "--------  --------\n";
        // I.dump();
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
        // for (Instruction *aa : SuccInst[&I]) {
        //   aa->dump();
        // }
        Worklist.push_back(&I);
      }
    }

    for (DenseMap<Instruction *, DenseSet<Instruction *>>::iterator iter =
             SuccInst.begin();
         iter != SuccInst.end(); iter++) {
      for (Instruction *I : iter->second) {
        PredInst[I].insert(iter->first);
      }
    }

    // for (BasicBlock &BB : F) {
    //   errs() << "  " << BB.getName() << ":\n";
    //   for (Instruction &I : BB) {
    //     errs() << "----\n";
    //     for (Instruction *ii : PredInst[&I]) {
    //       ii->dump();
    //       // errs() << ii << "\n";
    //     }
    //     errs() << "----\n";
    //     I.dump();
    //     // errs() << &I << "\n";
    //     errs() << "=====\n";
    //     for (Instruction *ii : SuccInst[&I]) {
    //       ii->dump();
    //       // errs() << ii << "\n";
    //     }
    //     errs() << "=====\n\n";
    //   }
    // }

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

          // PHINode *PHII = dyn_cast<PHINode>(SI);
          // BasicBlock *bb = I->getParent();
          // Value *v = PHII->getIncomingValueForBlock(bb);
          // // PHII->dump();
          // // I->dump();
          // // bb->dump();
          // // errs() << v->hasName() << ":" << v->getName() << "\n";

          // if (v->hasName()) {
          //   // Instruction &I_last = bb->back();
          //   liveOut[I].insert(v->getName());
          //   // PHII->dump();
          //   // I->dump();
          //   // errs() << v->getName() << "\n-----\n";
          // }
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

    // for (BasicBlock &BB : F) {
    //   for (size_t t = 0; t < 15; t++) {
    //     DenseSet<StringRef> succ_in;
    //     for (BasicBlock::reverse_iterator Inst = BB.rbegin(), E = BB.rend();
    //          Inst != E; Inst++) {
    //       Instruction &I = *Inst;
    //       if (isa<PHINode>(I)) {
    //         liveInB[&BB].insert(I.getName());
    //         continue;
    //       }
    //       liveOut[&I] = succ_in;

    //       if (strcmp(I.getOpcodeName(), "ret") == 0) {
    //         assert(liveOut[&I].size == 0 &&
    //                "The liveOut of a return instruction is not empty");
    //         // liveOut[&I].clear();
    //       }
    //       User::op_iterator OI, OE;
    //       for (OI = I.op_begin(), OE = I.op_end(); OI != OE; OI++) {
    //         Value *val = *OI;
    //         if (isa<Instruction>(val) || isa<Argument>(val)) {
    //           liveIn[&I].insert(val->getName());
    //         }
    //       }
    //       DenseSet<StringRef> tmp_out = liveOut[&I];
    //       if (tmp_out.find(I.getName()) != tmp_out.end()) {
    //         tmp_out.erase(I.getName());
    //       }
    //       for (StringRef str : tmp_out) {
    //         liveIn[&I].insert(str);
    //       }
    //       succ_in = liveIn[&I];
    //     }
    //     // BasicBlock::iterator I_start = BB.begin();
    //     // while (isa<PHINode>(I_start)) {
    //     //   I_start++;
    //     // }
    //     // Instruction &I_start_real = *I_start;
    //     // liveInB[&BB] = liveIn[&I_start_real];
    //     // Instruction &I_end = *BB.rbegin();
    //     // liveOutB[&BB] = liveOut[&I_end];
    //     // for (BasicBlock &BB : F) {
    //     //   for (BasicBlock *Pred : successors(&BB)) {
    //     //     for (StringRef str : liveInB[Pred]) {
    //     //       liveOutB[&BB].insert(str);
    //     //     }
    //     //   }
    //     // }
    //     // for (BasicBlock &BB : F) {
    //     //   BasicBlock::iterator I_start = BB.begin();
    //     //   while (isa<PHINode>(I_start)) {
    //     //     I_start++;
    //     //   }
    //     //   Instruction &I_start_real = *I_start;
    //     //   liveIn[&I_start_real] = liveInB[&BB];
    //     //   Instruction &I_end = *BB.rbegin();
    //     //   liveOut[&I_end] = liveOutB[&BB];
    //     // }
    //   }
    // }

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
    Y("function-liveness", "CSE521: Function Liveness", false, false);