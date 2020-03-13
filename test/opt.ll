; ModuleID = 'test.ll'
source_filename = "test.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.15.0"

@g = common global i32 0, align 4

; Function Attrs: noinline nounwind ssp uwtable
define i32 @g_incr(i32 %c) #0 {
entry:
  %tmp1 = load i32, i32* @g, align 4
  %add = add nsw i32 %tmp1, %c
  store i32 %add, i32* @g, align 4
  %tmp2 = load i32, i32* @g, align 4
  ret i32 %tmp2
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @loop(i32 %a, i32 %b, i32 %c) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ %a, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, %b
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call = call i32 @g_incr(i32 %c)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %tmp6 = load i32, i32* @g, align 4
  %add = add nsw i32 0, %tmp6
  ret i32 %add
}

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.0 (https://github.com/llvm/llvm-project.git e91e1df6ab74006e96b0cca94192e935542705a4)"}
