; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple powerpc64le -verify-machineinstrs \
; RUN:   | FileCheck -check-prefix=VSX %s
; RUN: llc < %s -mtriple powerpc64le -verify-machineinstrs -mattr=-vsx \
; RUN:   | FileCheck -check-prefix=NO-VSX %s

define double @test_mul_sub_f64(double %a, double %b, double %c) {
; VSX-LABEL: test_mul_sub_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubadp 1, 2, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_mul_sub_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 2, 3, 1
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul contract reassoc double %b, %c
  %1 = fsub contract reassoc double %a, %0
  ret double %1
}

define double @test_2mul_sub_f64(double %a, double %b, double %c, double %d) {
; VSX-LABEL: test_2mul_sub_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsmuldp 0, 3, 4
; VSX-NEXT:    xsmsubadp 0, 1, 2
; VSX-NEXT:    fmr 1, 0
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_2mul_sub_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fmul 0, 3, 4
; NO-VSX-NEXT:    fmsub 1, 1, 2, 0
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul contract reassoc double %a, %b
  %1 = fmul contract reassoc double %c, %d
  %2 = fsub contract reassoc double %0, %1
  ret double %2
}

define double @test_neg_fma_f64(double %a, double %b, double %c) {
; VSX-LABEL: test_neg_fma_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubadp 3, 1, 2
; VSX-NEXT:    fmr 1, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_neg_fma_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 1, 2, 3
; NO-VSX-NEXT:    blr
entry:
  %0 = fsub contract reassoc double -0.0, %a
  %1 = call contract reassoc double @llvm.fma.f64(double %0, double %b,
                                                  double %c)
  ret double %1
}

define float @test_mul_sub_f32(float %a, float %b, float %c) {
; VSX-LABEL: test_mul_sub_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubasp 1, 2, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_mul_sub_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsubs 1, 2, 3, 1
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul contract reassoc float %b, %c
  %1 = fsub contract reassoc float %a, %0
  ret float %1
}

define float @test_2mul_sub_f32(float %a, float %b, float %c, float %d) {
; VSX-LABEL: test_2mul_sub_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsmulsp 0, 3, 4
; VSX-NEXT:    xsmsubasp 0, 1, 2
; VSX-NEXT:    fmr 1, 0
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_2mul_sub_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fmuls 0, 3, 4
; NO-VSX-NEXT:    fmsubs 1, 1, 2, 0
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul contract reassoc float %a, %b
  %1 = fmul contract reassoc float %c, %d
  %2 = fsub contract reassoc float %0, %1
  ret float %2
}

define float @test_neg_fma_f32(float %a, float %b, float %c) {
; VSX-LABEL: test_neg_fma_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubasp 3, 1, 2
; VSX-NEXT:    fmr 1, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_neg_fma_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsubs 1, 1, 2, 3
; NO-VSX-NEXT:    blr
entry:
  %0 = fsub contract reassoc float -0.0, %a
  %1 = call contract reassoc float @llvm.fma.f32(float %0, float %b, float %c)
  ret float %1
}

define <2 x double> @test_neg_fma_v2f64(<2 x double> %a, <2 x double> %b,
; VSX-LABEL: test_neg_fma_v2f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xvnmsubadp 36, 34, 35
; VSX-NEXT:    vmr 2, 4
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_neg_fma_v2f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 1, 3, 5
; NO-VSX-NEXT:    fnmsub 2, 2, 4, 6
; NO-VSX-NEXT:    blr
                                        <2 x double> %c) {
entry:
  %0 = fsub contract reassoc <2 x double> <double -0.0, double -0.0>, %a
  %1 = call contract reassoc <2 x double> @llvm.fma.v2f64(<2 x double> %0,
                                                          <2 x double> %b,
                                                          <2 x double> %c)
  ret <2 x double> %1
}

define <4 x float> @test_neg_fma_v4f32(<4 x float> %a, <4 x float> %b,
; VSX-LABEL: test_neg_fma_v4f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xvnmsubasp 36, 34, 35
; VSX-NEXT:    vmr 2, 4
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_neg_fma_v4f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    vspltisb 5, -1
; NO-VSX-NEXT:    vslw 5, 5, 5
; NO-VSX-NEXT:    vsubfp 2, 5, 2
; NO-VSX-NEXT:    vmaddfp 2, 2, 3, 4
; NO-VSX-NEXT:    blr
                                       <4 x float> %c) {
entry:
  %0 = fsub contract reassoc <4 x float> <float -0.0, float -0.0, float -0.0,
                                          float -0.0>, %a
  %1 = call contract reassoc <4 x float> @llvm.fma.v4f32(<4 x float> %0,
                                                         <4 x float> %b,
                                                         <4 x float> %c)
  ret <4 x float> %1
}

define double @test_fast_mul_sub_f64(double %a, double %b, double %c) {
; VSX-LABEL: test_fast_mul_sub_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubadp 1, 2, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_mul_sub_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 2, 3, 1
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul fast double %b, %c
  %1 = fsub fast double %a, %0
  ret double %1
}

define double @test_fast_2mul_sub_f64(double %a, double %b, double %c,
; VSX-LABEL: test_fast_2mul_sub_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsmuldp 0, 3, 4
; VSX-NEXT:    xsmsubadp 0, 1, 2
; VSX-NEXT:    fmr 1, 0
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_2mul_sub_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fmul 0, 3, 4
; NO-VSX-NEXT:    fmsub 1, 1, 2, 0
; NO-VSX-NEXT:    blr
                                      double %d) {
entry:
  %0 = fmul fast double %a, %b
  %1 = fmul fast double %c, %d
  %2 = fsub fast double %0, %1
  ret double %2
}

define double @test_fast_neg_fma_f64(double %a, double %b, double %c) {
; VSX-LABEL: test_fast_neg_fma_f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubadp 3, 1, 2
; VSX-NEXT:    fmr 1, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_neg_fma_f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 1, 2, 3
; NO-VSX-NEXT:    blr
entry:
  %0 = fsub fast double -0.0, %a
  %1 = call fast double @llvm.fma.f64(double %0, double %b, double %c)
  ret double %1
}

define float @test_fast_mul_sub_f32(float %a, float %b, float %c) {
; VSX-LABEL: test_fast_mul_sub_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubasp 1, 2, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_mul_sub_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsubs 1, 2, 3, 1
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul fast float %b, %c
  %1 = fsub fast float %a, %0
  ret float %1
}

define float @test_fast_2mul_sub_f32(float %a, float %b, float %c, float %d) {
; VSX-LABEL: test_fast_2mul_sub_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsmulsp 0, 3, 4
; VSX-NEXT:    xsmsubasp 0, 1, 2
; VSX-NEXT:    fmr 1, 0
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_2mul_sub_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fmuls 0, 3, 4
; NO-VSX-NEXT:    fmsubs 1, 1, 2, 0
; NO-VSX-NEXT:    blr
entry:
  %0 = fmul fast float %a, %b
  %1 = fmul fast float %c, %d
  %2 = fsub fast float %0, %1
  ret float %2
}

define float @test_fast_neg_fma_f32(float %a, float %b, float %c) {
; VSX-LABEL: test_fast_neg_fma_f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xsnmsubasp 3, 1, 2
; VSX-NEXT:    fmr 1, 3
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_neg_fma_f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsubs 1, 1, 2, 3
; NO-VSX-NEXT:    blr
entry:
  %0 = fsub fast float -0.0, %a
  %1 = call fast float @llvm.fma.f32(float %0, float %b, float %c)
  ret float %1
}

define <2 x double> @test_fast_neg_fma_v2f64(<2 x double> %a, <2 x double> %b,
; VSX-LABEL: test_fast_neg_fma_v2f64:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xvnmsubadp 36, 34, 35
; VSX-NEXT:    vmr 2, 4
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_neg_fma_v2f64:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    fnmsub 1, 1, 3, 5
; NO-VSX-NEXT:    fnmsub 2, 2, 4, 6
; NO-VSX-NEXT:    blr
                                             <2 x double> %c) {
entry:
  %0 = fsub fast <2 x double> <double -0.0, double -0.0>, %a
  %1 = call fast <2 x double> @llvm.fma.v2f64(<2 x double> %0, <2 x double> %b,
                                              <2 x double> %c)
  ret <2 x double> %1
}

define <4 x float> @test_fast_neg_fma_v4f32(<4 x float> %a, <4 x float> %b,
; VSX-LABEL: test_fast_neg_fma_v4f32:
; VSX:       # %bb.0: # %entry
; VSX-NEXT:    xvnmsubasp 36, 34, 35
; VSX-NEXT:    vmr 2, 4
; VSX-NEXT:    blr
;
; NO-VSX-LABEL: test_fast_neg_fma_v4f32:
; NO-VSX:       # %bb.0: # %entry
; NO-VSX-NEXT:    vspltisb 5, -1
; NO-VSX-NEXT:    vslw 5, 5, 5
; NO-VSX-NEXT:    vsubfp 2, 5, 2
; NO-VSX-NEXT:    vmaddfp 2, 2, 3, 4
; NO-VSX-NEXT:    blr
                                            <4 x float> %c) {
entry:
  %0 = fsub fast <4 x float> <float -0.0, float -0.0, float -0.0,
                              float -0.0>, %a
  %1 = call fast <4 x float> @llvm.fma.v4f32(<4 x float> %0, <4 x float> %b,
                                             <4 x float> %c)
  ret <4 x float> %1
}

declare float  @llvm.fma.f32(float  %a, float  %b, float  %c)
declare double @llvm.fma.f64(double %a, double %b, double %c)
declare <4 x float> @llvm.fma.v4f32(<4 x float> %a, <4 x float> %b,
                                                    <4 x float> %c)
declare <2 x double> @llvm.fma.v2f64(<2 x double> %a, <2 x double> %b,
                                                      <2 x double> %c)
