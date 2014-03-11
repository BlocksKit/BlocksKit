/* -----------------------------------------------------------------------
   debug.c - Copyright (c) 1996 Red Hat, Inc.

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
   ----------------------------------------------------------------------- */

#include <ffi_mini.h>
#include <ffi_common_mini.h>
#include <stdlib.h>

#if defined (FFI_DEBUG)
#include <stdio.h>

/* General debugging routines */

void ffi_mini_stop_here(void)
{
  /* This function is only useful for debugging purposes.
     Place a breakpoint on ffi_mini_stop_here to be notified of
     significant events. */
}

/* This function should only be called via the FFI_ASSERT() macro */

void ffi_mini_assert(char *expr, char *file, int line)
{
  fprintf(stderr, "ASSERTION FAILURE: %s at %s:%d\n", expr, file, line);
  ffi_mini_stop_here();
  abort();
}

/* Perform a sanity check on an ffim_type structure */

void ffi_mini_type_test(ffim_type *a, char *file, int line)
{
  FFI_ASSERT_AT(a != NULL, file, line);

  FFI_ASSERT_AT(a->type <= FFIM_TYPE_LAST, file, line);
  FFI_ASSERT_AT(a->type == FFIM_TYPE_VOID || a->size > 0, file, line);
  FFI_ASSERT_AT(a->type == FFIM_TYPE_VOID || a->alignment > 0, file, line);
  FFI_ASSERT_AT(a->type != FFIM_TYPE_STRUCT || a->elements != NULL, file, line);

}

#endif /* defined (FFI_DEBUG) */
