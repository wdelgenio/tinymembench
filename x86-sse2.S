/*
 * Copyright © 2011 Siarhei Siamashka <siarhei.siamashka@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#if defined(__i386__) || defined(__amd64__)

.intel_syntax noprefix
.text

#define PREFETCH_DISTANCE 256

.macro asm_function_helper function_name
    .global \function_name
.func \function_name
\function_name:
#ifdef __amd64__
  #ifdef _WIN64
    .set DST,  rcx
    .set SRC,  rdx
    .set SIZE, r8
  #else
    .set DST,  rdi
    .set SRC,  rsi
    .set SIZE, rdx
  #endif
#else
    mov  eax,  [esp + 4]
    mov  ecx,  [esp + 8]
    mov  edx,  [esp + 12]
    .set DST,  eax
    .set SRC,  ecx
    .set SIZE, edx
#endif
.endm

.macro asm_function function_name
#if defined(_WIN32) && !defined(_WIN64)
    asm_function_helper _\function_name
#else
    asm_function_helper \function_name
#endif
.endm

.macro push3 a, b, c
    push \a
    push \b
    push \c
.endm

.macro pop3 a, b, c
    pop \c
    pop \b
    pop \a
.endm

/*****************************************************************************/

asm_function aligned_block_copy_movsb
0:
#ifdef __amd64__
    push3       rdi rsi rcx
    push3       DST SRC SIZE
    pop3        rdi rsi rcx
    rep movsb
    pop3        rdi rsi rcx
#else
    push3       edi esi ecx
    push3       DST SRC SIZE
    pop3        edi esi ecx
    rep movsb
    pop3        edi esi ecx
#endif
    ret
.endfunc

asm_function aligned_block_copy_movsd
0:
#ifdef __amd64__
    push3       rdi rsi rcx
    push3       DST SRC SIZE
    pop3        rdi rsi rcx
    sar         rcx, 2
    rep movsd
    pop3        rdi rsi rcx
#else
    push3       edi esi ecx
    push3       DST SRC SIZE
    pop3        edi esi ecx
    sar         ecx, 2
    rep movsd
    pop3        edi esi ecx
#endif
    ret
.endfunc

asm_function aligned_block_copy_sse2
0:
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movdqa      [DST + 0],  xmm0
    movdqa      [DST + 16], xmm1
    movdqa      [DST + 32], xmm2
    movdqa      [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_nt_sse2
0:
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movntdq     [DST + 0],  xmm0
    movntdq     [DST + 16], xmm1
    movntdq     [DST + 32], xmm2
    movntdq     [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_pf32_sse2
0:
    prefetchnta [SRC + PREFETCH_DISTANCE]
    prefetchnta [SRC + PREFETCH_DISTANCE + 32]
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movdqa      [DST + 0],  xmm0
    movdqa      [DST + 16], xmm1
    movdqa      [DST + 32], xmm2
    movdqa      [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_nt_pf32_sse2
0:
    prefetchnta [SRC + PREFETCH_DISTANCE]
    prefetchnta [SRC + PREFETCH_DISTANCE + 32]
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movntdq     [DST + 0],  xmm0
    movntdq     [DST + 16], xmm1
    movntdq     [DST + 32], xmm2
    movntdq     [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_pf64_sse2
0:
    prefetchnta [SRC + PREFETCH_DISTANCE]
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movdqa      [DST + 0],  xmm0
    movdqa      [DST + 16], xmm1
    movdqa      [DST + 32], xmm2
    movdqa      [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_nt_pf64_sse2
0:
    prefetchnta [SRC + PREFETCH_DISTANCE]
    movdqa      xmm0,       [SRC + 0]
    movdqa      xmm1,       [SRC + 16]
    movdqa      xmm2,       [SRC + 32]
    movdqa      xmm3,       [SRC + 48]
    movntdq     [DST + 0],  xmm0
    movntdq     [DST + 16], xmm1
    movntdq     [DST + 32], xmm2
    movntdq     [DST + 48], xmm3
    add         SRC,        64
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_fill_sse2
    movdqa      xmm0,       [SRC + 0]
0:
    movdqa      [DST + 0],  xmm0
    movdqa      [DST + 16], xmm0
    movdqa      [DST + 32], xmm0
    movdqa      [DST + 48], xmm0
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_fill_nt_sse2
    movdqa      xmm0,       [SRC + 0]
0:
    movntdq     [DST + 0],  xmm0
    movntdq     [DST + 16], xmm0
    movntdq     [DST + 32], xmm0
    movntdq     [DST + 48], xmm0
    add         DST,        64
    sub         SIZE,       64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_avx
0:
    vmovdqa      ymm0,       [SRC + 0]
    vmovdqa      ymm1,       [SRC + 32]
    vmovdqa      [DST + 0],  ymm0
    vmovdqa      [DST + 32], ymm1
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy256_avx
0:
    vmovdqa      ymm0,       [SRC + 0]
    vmovdqa      ymm1,       [SRC + 32]
    vmovdqa      ymm2,       [SRC + 64]
    vmovdqa      ymm3,       [SRC + 96]
    vmovdqa      ymm4,       [SRC + 128]
    vmovdqa      ymm5,       [SRC + 160]
    vmovdqa      ymm6,       [SRC + 192]
    vmovdqa      ymm7,       [SRC + 224]
    vmovdqa      [DST + 0],     ymm0
    vmovdqa      [DST + 32],    ymm1
    vmovdqa      [DST + 64],    ymm2
    vmovdqa      [DST + 96],    ymm3
    vmovdqa      [DST + 128],   ymm4
    vmovdqa      [DST + 160],   ymm5
    vmovdqa      [DST + 192],   ymm6
    vmovdqa      [DST + 224],   ymm7
    add         SRC,        256
    add         DST,        256
    sub         SIZE, 256
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy_avx512
0:
    vmovdqa64      zmm0,       [SRC + 0]
    vmovdqa64      [DST + 0],  zmm0
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

asm_function aligned_block_copy512_avx512
0:
    vmovdqa64      zmm0,       [SRC + 0]
    vmovdqa64      zmm1,       [SRC + 64]
    vmovdqa64      zmm2,       [SRC + 128]
    vmovdqa64      zmm3,       [SRC + 192]
    vmovdqa64      zmm4,       [SRC + 256]
    vmovdqa64      zmm5,       [SRC + 320]
    vmovdqa64      zmm6,       [SRC + 384]
    vmovdqa64      zmm7,       [SRC + 448]
    vmovdqa64      [DST + 0],     zmm0
    vmovdqa64      [DST + 64],    zmm1
    vmovdqa64      [DST + 128],    zmm2
    vmovdqa64      [DST + 192],    zmm3
    vmovdqa64      [DST + 256],   zmm4
    vmovdqa64      [DST + 320],   zmm5
    vmovdqa64      [DST + 384],   zmm6
    vmovdqa64      [DST + 448],   zmm7
    add         SRC,        512
    add         DST,        512
    sub         SIZE, 512
    jg          0b
    ret
.endfunc

asm_function unaligned_block_copy_nt_f64_avx
0:
    prefetcht0   [SRC + PREFETCH_DISTANCE]
    vmovdqu    ymm0,       [SRC + 0]
    vmovdqu    ymm1,       [SRC + 32]
    vmovntdq      [DST + 0],  ymm0
    vmovntdq      [DST + 32], ymm1
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

asm_function unaligned_block_copy_nt_f64_avx512
0:
    prefetcht0   [SRC + PREFETCH_DISTANCE]
    vmovdqu64    zmm0,       [SRC + 0]
    vmovntdq     [DST + 0],  zmm0
    add         SRC,        64
    add         DST,        64
    sub         SIZE, 64
    jg          0b
    ret
.endfunc

/*****************************************************************************/

#endif
