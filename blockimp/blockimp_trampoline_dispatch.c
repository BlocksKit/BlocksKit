/*
 * blockimp_trampoline_dispatch.h
 * blockimp
 *
 * Author: Landon Fuller <landonf@plausible.coop>
 *
 * Copyright 2010-2011 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge,
 * to any person obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#if defined(__i386__)

asm(".text; .align 12; .globl _pl_blockimp_table_page");
asm("_pl_blockimp_table_page:");
asm("_block_tramp_dispatch:");

asm("pop     %eax; \
	andl    $0xfffffff8, %eax; \
	subl    $0x1000, %eax; \
	\
	movl    0x4(%esp), %ecx; \
	movl    %ecx, 0x8(%esp); \
	\
	movl    (%eax), %eax; \
	movl    %eax, 0x4(%esp); \
	\
	jmp    *0xc(%eax); \
	\
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3; \
	\
	calll _block_tramp_dispatch; \
	.align 3;");

#elif defined(__x86_64__)

asm(".text; .align 12; .globl _pl_blockimp_table_page");
asm("_pl_blockimp_table_page:");
asm("_block_tramp_dispatch:");

asm("pop    %r11; \
	and    $0xfffffffffffffff8, %r11; \
	sub    $0x1000, %r11; \
	\
	movq   %rdi, %rsi; \
	\
	movq   (%r11), %rdi; \
	\
	jmp *0x10(%rdi); \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4; \
	\
	call _block_tramp_dispatch; \
	.align 4;");

#elif defined(__arm__)

#import <arm/arch.h>

#if defined(_ARM_ARCH_6)

// armv6

asm(".text; .align 12; .globl _pl_blockimp_table_page");
asm("_pl_blockimp_table_page:");
asm("_block_tramp_dispatch:");
asm("sub r12, #0x8; \
	sub r12, #0x1000; \
	\
	mov r1, r0; \
	\
	ldr r0, [r12]; \
	\
	ldr pc, [r0, #0xc]; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch;");

#elif defined(_ARM_ARCH_7)

// armv7

asm(".text; .align 12; .globl _pl_blockimp_table_page;");
asm("_pl_blockimp_table_page:");
asm("_block_tramp_dispatch:");
asm("sub r12, #0x8; \
	sub r12, #0x1000; \
	\
	mov r1, r0; \
	\
	ldr r0, [r12]; \
	\
	ldr pc, [r0, #0xc]; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch; \
	\
	mov r12, pc; \
	b _block_tramp_dispatch;");

#else
#error Unknown ARM
#endif

#else
#error Unknown Architecture
#endif