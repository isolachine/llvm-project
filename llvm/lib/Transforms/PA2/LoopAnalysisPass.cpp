
#include "llvm/Analysis/LoopPass.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include <set>
#include <vector>

#include <iostream>

using namespace llvm;

namespace {

class LoopAnalysisInfo {
private:
public:
  StringRef func;
  unsigned int id;
  unsigned int depth;
  unsigned int bbCount;
  unsigned int instCount;
  unsigned int atomicsCount;
  unsigned int branchCount;
  bool hasSubLoops;

  LoopAnalysisInfo();
  ~LoopAnalysisInfo();
};

LoopAnalysisInfo::LoopAnalysisInfo() {
  bbCount = 0;
  instCount = 0;
  atomicsCount = 0;
  branchCount = 0;
}

LoopAnalysisInfo::~LoopAnalysisInfo() {}

class LoopAnalysisPass : public FunctionPass {
private:
  std::vector<LoopAnalysisInfo *> infoVec;
  std::set<BasicBlock *> countedBB;
  std::set<BranchInst *> countedBrInst;
  int counter;

public:
  static char ID;
  LoopAnalysisPass() : FunctionPass(ID) {}
  ~LoopAnalysisPass() {}

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<LoopInfoWrapperPass>();
    AU.setPreservesAll();
  }

  bool doInitialization(Module &M) override { return false; }

  bool doFinalization(Module &M) override {
    // print info from the universal infoVec

    return false;
  }

  bool runOnFunction(Function &F) override {
    std::vector<LoopAnalysisInfo *> infoVec;
    LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    for (LoopInfo::reverse_iterator i = LI.rbegin(); i != LI.rend(); i++) {
      Loop *loop = *i;
      analyseLoop(F, loop);
    }
    for (auto i : infoVec) {
      errs() << "<" << i->id << ">: ";
      errs() << "func=<" << i->func << ">, ";
      errs() << "depth=<" << i->depth << ">, ";
      StringRef sub = i->hasSubLoops ? "true" : "false";
      errs() << "subLoops=<" << sub << ">, ";
      errs() << "BBs=<" << i->bbCount << ">, ";
      errs() << "instrs=<" << i->instCount << ">, ";
      errs() << "atomics=<" << i->atomicsCount << ">, ";
      errs() << "branches=<" << i->branchCount << ">\n";
    }
    return false;
  }

  void analyseLoop(Function &F, Loop *loop) {
    LoopAnalysisInfo *loopInfo = new LoopAnalysisInfo();

    loopInfo->id = infoVec.size();
    loopInfo->func = F.getName();
    loopInfo->depth = loop->getLoopDepth() - 1;
    const std::vector<Loop *> subloopVec = loop->getSubLoops();
    loopInfo->hasSubLoops = subloopVec.size() > 0 ? true : false;
    infoVec.push_back(loopInfo);

    for (auto l : subloopVec) {
      analyseLoop(F, l);
    }

    for (Loop::block_iterator bb = loop->block_begin(); bb != loop->block_end();
         bb++) {
      BasicBlock *BB = *bb;
      if (countedBB.find(BB) == countedBB.end()) {
        loopInfo->bbCount++;
        countedBB.insert(BB);
      }
      for (Instruction &I : *BB) {
        if (I.isAtomic())
          loopInfo->atomicsCount++;
        if (BranchInst *BrI = dyn_cast<BranchInst>(&I)) {
          if (countedBrInst.find(BrI) == countedBrInst.end()) {
            loopInfo->branchCount++;
            countedBrInst.insert(BrI);
          }
        }
        loopInfo->instCount++;
      }
    }
  }
};
} // namespace

char LoopAnalysisPass::ID = 0;
static RegisterPass<LoopAnalysisPass>
    X("loop-analysis", "CSE521: Loop Information", false, false);