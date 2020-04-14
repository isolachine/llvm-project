; RUN:  llc -amdgpu-scalarize-global-loads=false  -march=amdgcn -mcpu=verde -verify-machineinstrs < %s | FileCheck -check-prefix=SI -check-prefix=FUNC %s
; RUN:  llc -amdgpu-scalarize-global-loads=false  -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -verify-machineinstrs -denormal-fp-math-f32=preserve-sign < %s | FileCheck -check-prefix=SI -check-prefix=FUNC -check-prefix=VI %s

; RUN:  llc -amdgpu-scalarize-global-loads=false  -mtriple=amdgcn--amdhsa -mcpu=fiji -denormal-fp-math-f32=ieee < %s | FileCheck -check-prefix=GCN -check-prefix=VI %s

; RUN:  llc -amdgpu-scalarize-global-loads=false  -march=r600 -mcpu=redwood < %s | FileCheck -check-prefix=EG -check-prefix=FUNC %s

; FUNC-LABEL: {{^}}udiv_i32:
; EG-NOT: SETGE_INT
; EG: CF_END

; SI: v_rcp_iflag_f32_e32
define amdgpu_kernel void @udiv_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %b = load i32, i32 addrspace(1)* %b_ptr
  %result = udiv i32 %a, %b
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}s_udiv_i32:
; SI: v_rcp_iflag_f32_e32
define amdgpu_kernel void @s_udiv_i32(i32 addrspace(1)* %out, i32 %a, i32 %b) {
  %result = udiv i32 %a, %b
  store i32 %result, i32 addrspace(1)* %out
  ret void
}


; The code generated by udiv is long and complex and may frequently
; change. The goal of this test is to make sure the ISel doesn't fail
; when it gets a v4i32 udiv

; FUNC-LABEL: {{^}}udiv_v2i32:
; EG: CF_END

; SI: v_rcp_iflag_f32_e32
; SI: v_rcp_iflag_f32_e32
; SI: s_endpgm
define amdgpu_kernel void @udiv_v2i32(<2 x i32> addrspace(1)* %out, <2 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <2 x i32>, <2 x i32> addrspace(1)* %in, i32 1
  %a = load <2 x i32>, <2 x i32> addrspace(1) * %in
  %b = load <2 x i32>, <2 x i32> addrspace(1) * %b_ptr
  %result = udiv <2 x i32> %a, %b
  store <2 x i32> %result, <2 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}udiv_v4i32:
; EG: CF_END
; SI: s_endpgm
define amdgpu_kernel void @udiv_v4i32(<4 x i32> addrspace(1)* %out, <4 x i32> addrspace(1)* %in) {
  %b_ptr = getelementptr <4 x i32>, <4 x i32> addrspace(1)* %in, i32 1
  %a = load <4 x i32>, <4 x i32> addrspace(1) * %in
  %b = load <4 x i32>, <4 x i32> addrspace(1) * %b_ptr
  %result = udiv <4 x i32> %a, %b
  store <4 x i32> %result, <4 x i32> addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}udiv_i32_div_pow2:
; SI: buffer_load_dword [[VAL:v[0-9]+]]
; SI: v_lshrrev_b32_e32 [[RESULT:v[0-9]+]], 4, [[VAL]]
; SI: buffer_store_dword [[RESULT]]
define amdgpu_kernel void @udiv_i32_div_pow2(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %result = udiv i32 %a, 16
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}udiv_i32_div_k_even:
; SI-DAG: buffer_load_dword [[VAL:v[0-9]+]]
; SI-DAG: s_mov_b32 [[K:s[0-9]+]], 0xfabbd9c1
; SI: v_mul_hi_u32 [[MULHI:v[0-9]+]], [[VAL]], [[K]]
; SI: v_lshrrev_b32_e32 [[RESULT:v[0-9]+]], 25, [[MULHI]]
; SI: buffer_store_dword [[RESULT]]
define amdgpu_kernel void @udiv_i32_div_k_even(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %result = udiv i32 %a, 34259182
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}udiv_i32_div_k_odd:
; SI-DAG: buffer_load_dword [[VAL:v[0-9]+]]
; SI-DAG: s_mov_b32 [[K:s[0-9]+]], 0x7d5deca3
; SI: v_mul_hi_u32 [[MULHI:v[0-9]+]], [[VAL]], [[K]]
; SI: v_lshrrev_b32_e32 [[RESULT:v[0-9]+]], 24, [[MULHI]]
; SI: buffer_store_dword [[RESULT]]
define amdgpu_kernel void @udiv_i32_div_k_odd(i32 addrspace(1)* %out, i32 addrspace(1)* %in) {
  %b_ptr = getelementptr i32, i32 addrspace(1)* %in, i32 1
  %a = load i32, i32 addrspace(1)* %in
  %result = udiv i32 %a, 34259183
  store i32 %result, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_udiv_i8:
; SI: v_rcp_iflag_f32
; SI: v_and_b32_e32 [[TRUNC:v[0-9]+]], 0xff, v{{[0-9]+}}
; SI: buffer_store_dword [[TRUNC]]
define amdgpu_kernel void @v_udiv_i8(i32 addrspace(1)* %out, i8 addrspace(1)* %in) {
  %den_ptr = getelementptr i8, i8 addrspace(1)* %in, i8 1
  %num = load i8, i8 addrspace(1) * %in
  %den = load i8, i8 addrspace(1) * %den_ptr
  %result = udiv i8 %num, %den
  %result.ext = zext i8 %result to i32
  store i32 %result.ext, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_udiv_i16:
; SI: v_rcp_iflag_f32
; SI: v_and_b32_e32 [[TRUNC:v[0-9]+]], 0xffff, v{{[0-9]+}}
; SI: buffer_store_dword [[TRUNC]]
define amdgpu_kernel void @v_udiv_i16(i32 addrspace(1)* %out, i16 addrspace(1)* %in) {
  %den_ptr = getelementptr i16, i16 addrspace(1)* %in, i16 1
  %num = load i16, i16 addrspace(1) * %in
  %den = load i16, i16 addrspace(1) * %den_ptr
  %result = udiv i16 %num, %den
  %result.ext = zext i16 %result to i32
  store i32 %result.ext, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_udiv_i23:
; SI: v_rcp_iflag_f32
; SI: v_and_b32_e32 [[TRUNC:v[0-9]+]], 0x7fffff, v{{[0-9]+}}
; SI: buffer_store_dword [[TRUNC]]
define amdgpu_kernel void @v_udiv_i23(i32 addrspace(1)* %out, i23 addrspace(1)* %in) {
  %den_ptr = getelementptr i23, i23 addrspace(1)* %in, i23 1
  %num = load i23, i23 addrspace(1) * %in
  %den = load i23, i23 addrspace(1) * %den_ptr
  %result = udiv i23 %num, %den
  %result.ext = zext i23 %result to i32
  store i32 %result.ext, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: {{^}}v_udiv_i24:
; SI-NOT: v_rcp_f32
define amdgpu_kernel void @v_udiv_i24(i32 addrspace(1)* %out, i24 addrspace(1)* %in) {
  %den_ptr = getelementptr i24, i24 addrspace(1)* %in, i24 1
  %num = load i24, i24 addrspace(1) * %in
  %den = load i24, i24 addrspace(1) * %den_ptr
  %result = udiv i24 %num, %den
  %result.ext = zext i24 %result to i32
  store i32 %result.ext, i32 addrspace(1)* %out
  ret void
}

; FUNC-LABEL: @scalarize_mulhu_4xi32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32
; SI: v_mul_hi_u32

define amdgpu_kernel void @scalarize_mulhu_4xi32(<4 x i32> addrspace(1)* nocapture readonly %in, <4 x i32> addrspace(1)* nocapture %out) {
  %1 = load <4 x i32>, <4 x i32> addrspace(1)* %in, align 16
  %2 = udiv <4 x i32> %1, <i32 53668, i32 53668, i32 53668, i32 53668>
  store <4 x i32> %2, <4 x i32> addrspace(1)* %out, align 16
  ret void
}

; FUNC-LABEL: {{^}}test_udiv2:
; SI: s_lshr_b32 s{{[0-9]}}, s{{[0-9]}}, 1
define amdgpu_kernel void @test_udiv2(i32 %p) {
  %i = udiv i32 %p, 2
  store volatile i32 %i, i32 addrspace(1)* undef
  ret void
}

; FUNC-LABEL: {{^}}test_udiv_3_mulhu:
; SI: v_mov_b32_e32 v{{[0-9]+}}, 0xaaaaaaab
; SI: v_mul_hi_u32 v0, {{s[0-9]+}}, {{v[0-9]+}}
; SI-NEXT: v_lshrrev_b32_e32 v0, 1, v0
define amdgpu_kernel void @test_udiv_3_mulhu(i32 %p) {
   %i = udiv i32 %p, 3
   store volatile i32 %i, i32 addrspace(1)* undef
   ret void
}

; GCN-LABEL: {{^}}fdiv_test_denormals
; VI: v_mad_f32 v{{[0-9]+}}, -v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
define amdgpu_kernel void @fdiv_test_denormals(i8 addrspace(1)* nocapture readonly %arg) {
bb:
  %tmp = load i8, i8 addrspace(1)* null, align 1
  %tmp1 = sext i8 %tmp to i32
  %tmp2 = getelementptr inbounds i8, i8 addrspace(1)* %arg, i64 undef
  %tmp3 = load i8, i8 addrspace(1)* %tmp2, align 1
  %tmp4 = sext i8 %tmp3 to i32
  %tmp5 = sdiv i32 %tmp1, %tmp4
  %tmp6 = trunc i32 %tmp5 to i8
  store i8 %tmp6, i8 addrspace(1)* null, align 1
  ret void
}
