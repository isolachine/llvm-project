; ModuleID = 'test.ll'
source_filename = "test.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@g = common global i32 0, align 4

; Function Attrs: noinline nounwind ssp uwtable
define i32 @erk(i32 %a, i32 %b) {
entry:
  %tmp1 = load i32, i32* @g, align 4
  %tmp1023 = icmp sgt i32 %b, 0
  br i1 %tmp1023, label %bb7, label %bb12

bb7: ; preds = %bb7, %entry
  %i.020.0 = phi i32 [0, %entry], [%indvar.next, %bb7] 
  %ret.018.0 = phi i32 [0, %entry], [%tmp4, %bb7]
  %tmp4 = mul i32 %ret.018.0, %a
  %indvar.next = add i32 %i.020.0, 1 
  %exitcond = icmp eq i32 %indvar.next, %b 
  br i1 %exitcond, label %bb12, label %bb7
  
bb12: ; preds = %bb7, %entry
  %ret.018.1 = phi i32 [0, %entry], [%tmp4, %bb7]
  %tmp15 = add i32 %ret.018.1, %tmp1 
  ret i32 %tmp15
}

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (https://github.com/llvm/llvm-project.git e91e1df6ab74006e96b0cca94192e935542705a4)"}
