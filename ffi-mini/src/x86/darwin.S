/* -----------------------------------------------------------------------
   darwin.S - Copyright (c) 1996, 1998, 2001, 2002, 2003, 2005  Red Hat, Inc.
	Copyright (C) 2008  Free Software Foundation, Inc.

   X86 Foreign Function Interface

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   ``Software''), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be included
   in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
   DEALINGS IN THE SOFTWARE.
   -----------------------------------------------------------------------
   */

#if defined (__i386__) && !defined (__x86_64__)

#define LIBFFI_ASM	
#include <fficonfig_mini.h>
#include <ffi_mini.h>

.text

.globl _ffi_mini_prep_args

	.align 4
.globl _ffi_mini_call_SYSV

_ffi_mini_call_SYSV:
.LFB1:
        pushl %ebp
.LCFI0:
        movl  %esp,%ebp
.LCFI1:
        subl $8,%esp
	/* Make room for all of the new args.  */
	movl  16(%ebp),%ecx
	subl  %ecx,%esp

	movl  %esp,%eax

	/* Place all of the ffi_mini_prep_args in position  */
	subl  $8,%esp
	pushl 12(%ebp)
	pushl %eax
	call  *8(%ebp)

	/* Return stack to previous state and call the function  */
	addl  $16,%esp	

	call  *28(%ebp)

	/* Load %ecx with the return type code  */
	movl  20(%ebp),%ecx	

	/* Protect %esi.  We're going to pop it in the epilogue.  */
	pushl %esi

	/* If the return value pointer is NULL, assume no return value.  */
	cmpl  $0,24(%ebp)
	jne  0f

	/* Even if there is no space for the return value, we are 
	   obliged to handle floating-point values.  */
	cmpl  $FFIM_TYPE_FLOAT,%ecx
	jne   noretval
	fstp  %st(0)

	jmp   epilogue
0:
	.align 4
	call 1f
.Lstore_table:
	.long   noretval-.Lstore_table		/* FFIM_TYPE_VOID */
	.long   retint-.Lstore_table		/* FFIM_TYPE_INT */
	.long   retfloat-.Lstore_table		/* FFIM_TYPE_FLOAT */
	.long   retdouble-.Lstore_table		/* FFIM_TYPE_DOUBLE */
	.long   retlongdouble-.Lstore_table     /* FFIM_TYPE_LONGDOUBLE */
	.long   retuint8-.Lstore_table		/* FFIM_TYPE_UINT8 */
	.long   retsint8-.Lstore_table		/* FFIM_TYPE_SINT8 */
	.long   retuint16-.Lstore_table		/* FFIM_TYPE_UINT16 */
	.long   retsint16-.Lstore_table		/* FFIM_TYPE_SINT16 */
	.long   retint-.Lstore_table		/* FFIM_TYPE_UINT32 */
	.long   retint-.Lstore_table		/* FFIM_TYPE_SINT32 */
	.long   retint64-.Lstore_table		/* FFIM_TYPE_UINT64 */
	.long   retint64-.Lstore_table		/* FFIM_TYPE_SINT64 */
	.long   retstruct-.Lstore_table		/* FFIM_TYPE_STRUCT */
	.long   retint-.Lstore_table		/* FFIM_TYPE_POINTER */
	.long   retstruct1b-.Lstore_table	/* FFIM_TYPE_SMALL_STRUCT_1B */
	.long   retstruct2b-.Lstore_table	/* FFIM_TYPE_SMALL_STRUCT_2B */
1:
	pop  %esi
	add  (%esi, %ecx, 4), %esi
	jmp  *%esi

	/* Sign/zero extend as appropriate.  */
retsint8:
	movsbl  %al, %eax
	jmp  retint

retsint16:
	movswl  %ax, %eax
	jmp  retint

retuint8:
	movzbl  %al, %eax
	jmp  retint

retuint16:
	movzwl  %ax, %eax
	jmp  retint

retfloat:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	fstps (%ecx)
	jmp   epilogue

retdouble:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	fstpl (%ecx)
	jmp   epilogue

retlongdouble:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	fstpt (%ecx)
	jmp   epilogue

retint64:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	movl  %eax,0(%ecx)
	movl  %edx,4(%ecx)
	jmp   epilogue

retstruct1b:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	movb  %al,0(%ecx)
	jmp   epilogue

retstruct2b:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	movw  %ax,0(%ecx)
	jmp   epilogue

retint:
	/* Load %ecx with the pointer to storage for the return value  */
	movl  24(%ebp),%ecx
	movl  %eax,0(%ecx)

retstruct:
	/* Nothing to do!  */

noretval:
epilogue:
	popl %esi
	movl %ebp,%esp
	popl %ebp
	ret

.LFE1:
.ffi_mini_call_SYSV_end:

#endif /* defined (__i386__) && !defined (__x86_64__) */
