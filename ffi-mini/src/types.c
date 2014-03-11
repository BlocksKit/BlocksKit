/* -----------------------------------------------------------------------
   types.c - Copyright (c) 1996, 1998  Red Hat, Inc.
   
   Predefined ffim_types needed by libffi.

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

/* Hide the basic type definitions from the header file, so that we
   can redefine them here as "const".  */
#define LIBFFI_HIDE_BASIC_TYPES

#include <ffi_mini.h>
#include <ffi_common_mini.h>

/* Type definitions */

#define FFIM_TYPEDEF(name, type, id)		\
struct struct_align_##name {			\
  char c;					\
  type x;					\
};						\
const ffim_type ffim_type_##name = {		\
  sizeof(type),					\
  offsetof(struct struct_align_##name, x),	\
  id, NULL					\
}

/* Size and alignment are fake here. They must not be 0. */
const ffim_type ffim_type_void = {
  1, 1, FFIM_TYPE_VOID, NULL
};

FFIM_TYPEDEF(uint8, UINT8, FFIM_TYPE_UINT8);
FFIM_TYPEDEF(sint8, SINT8, FFIM_TYPE_SINT8);
FFIM_TYPEDEF(uint16, UINT16, FFIM_TYPE_UINT16);
FFIM_TYPEDEF(sint16, SINT16, FFIM_TYPE_SINT16);
FFIM_TYPEDEF(uint32, UINT32, FFIM_TYPE_UINT32);
FFIM_TYPEDEF(sint32, SINT32, FFIM_TYPE_SINT32);
FFIM_TYPEDEF(uint64, UINT64, FFIM_TYPE_UINT64);
FFIM_TYPEDEF(sint64, SINT64, FFIM_TYPE_SINT64);

FFIM_TYPEDEF(pointer, void*, FFIM_TYPE_POINTER);

FFIM_TYPEDEF(float, float, FFIM_TYPE_FLOAT);
FFIM_TYPEDEF(double, double, FFIM_TYPE_DOUBLE);

#if FFIM_TYPE_LONGDOUBLE != FFIM_TYPE_DOUBLE
FFIM_TYPEDEF(longdouble, long double, FFIM_TYPE_LONGDOUBLE);
#endif
