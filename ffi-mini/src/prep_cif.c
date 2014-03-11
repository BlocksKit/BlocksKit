/* -----------------------------------------------------------------------
   prep_cif.c - Copyright (c) 2011, 2012  Anthony Green
                Copyright (c) 1996, 1998, 2007  Red Hat, Inc.

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

/* Round up to FFIM_SIZEOF_ARG. */

#define STACK_ARG_SIZE(x) ALIGN(x, FFIM_SIZEOF_ARG)

/* Perform machine independent initialization of aggregate type
   specifications. */

static ffim_status initialize_aggregate(ffim_type *arg)
{
  ffim_type **ptr;

  if (UNLIKELY(arg == NULL || arg->elements == NULL))
    return FFIM_BAD_TYPEDEF;

  arg->size = 0;
  arg->alignment = 0;

  ptr = &(arg->elements[0]);

  if (UNLIKELY(ptr == 0))
    return FFIM_BAD_TYPEDEF;

  while ((*ptr) != NULL)
    {
      if (UNLIKELY(((*ptr)->size == 0)
		    && (initialize_aggregate((*ptr)) != FFIM_OK)))
	return FFIM_BAD_TYPEDEF;

      /* Perform a sanity check on the argument type */
      FFI_ASSERT_VALID_TYPE(*ptr);

      arg->size = ALIGN(arg->size, (*ptr)->alignment);
      arg->size += (*ptr)->size;

      arg->alignment = (arg->alignment > (*ptr)->alignment) ?
	arg->alignment : (*ptr)->alignment;

      ptr++;
    }

  /* Structure size includes tail padding.  This is important for
     structures that fit in one register on ABIs like the PowerPC64
     Linux ABI that right justify small structs in a register.
     It's also needed for nested structure layout, for example
     struct A { long a; char b; }; struct B { struct A x; char y; };
     should find y at an offset of 2*sizeof(long) and result in a
     total size of 3*sizeof(long).  */
  arg->size = ALIGN (arg->size, arg->alignment);

  /* On some targets, the ABI defines that structures have an additional
     alignment beyond the "natural" one based on their elements.  */
#ifdef FFI_AGGREGATE_ALIGNMENT
  if (FFI_AGGREGATE_ALIGNMENT > arg->alignment)
    arg->alignment = FFI_AGGREGATE_ALIGNMENT;
#endif

  if (arg->size == 0)
    return FFIM_BAD_TYPEDEF;
  else
    return FFIM_OK;
}

#ifndef __CRIS__
/* The CRIS ABI specifies structure elements to have byte
   alignment only, so it completely overrides this functions,
   which assumes "natural" alignment and padding.  */

/* Perform machine independent ffim_cif preparation, then call
   machine dependent routine. */

/* For non variadic functions isvariadic should be 0 and
   nfixedargs==ntotalargs.

   For variadic calls, isvariadic should be 1 and nfixedargs
   and ntotalargs set as appropriate. nfixedargs must always be >=1 */


static ffim_status FFI_HIDDEN ffi_mini_prep_cif_core(ffim_cif *cif, ffim_abi abi,
			     unsigned int isvariadic,
                             unsigned int nfixedargs,
                             unsigned int ntotalargs,
			     ffim_type *rtype, ffim_type **atypes)
{
  unsigned bytes = 0;
  unsigned int i;
  ffim_type **ptr;

  FFI_ASSERT(cif != NULL);
  FFI_ASSERT((!isvariadic) || (nfixedargs >= 1));
  FFI_ASSERT(nfixedargs <= ntotalargs);

#ifndef X86_WIN32
  if (! (abi > FFIM_FIRST_ABI && abi < FFIM_LAST_ABI))
    return FFIM_BAD_ABI;
#else
  if (! (abi > FFIM_FIRST_ABI && abi < FFIM_LAST_ABI || abi == FFI_THISCALL))
    return FFIM_BAD_ABI;
#endif

  if (cif == NULL)
  return FFIM_BAD_TYPEDEF;

  cif->abi = abi;
  cif->arg_types = atypes;
  cif->nargs = ntotalargs;
  cif->rtype = rtype;

  cif->flags = 0;

#if HAVE_LONG_DOUBLE_VARIANT
  ffi_mini_prep_types (abi);
#endif

  /* Initialize the return type if necessary */
  if ((cif->rtype->size == 0) && (initialize_aggregate(cif->rtype) != FFIM_OK))
    return FFIM_BAD_TYPEDEF;

  /* Perform a sanity check on the return type */
  FFI_ASSERT_VALID_TYPE(cif->rtype);

  /* x86, x86-64 and s390 stack space allocation is handled in prep_machdep. */
#if !defined M68K && !defined X86_ANY && !defined S390 && !defined PA
  /* Make space for the return structure pointer */
  if (cif->rtype->type == FFIM_TYPE_STRUCT
#ifdef SPARC
      && (cif->abi != FFI_V9 || cif->rtype->size > 32)
#endif
#ifdef TILE
      && (cif->rtype->size > 10 * FFIM_SIZEOF_ARG)
#endif
#ifdef XTENSA
      && (cif->rtype->size > 16)
#endif
#ifdef NIOS2
      && (cif->rtype->size > 8)
#endif
     )
    bytes = STACK_ARG_SIZE(sizeof(void*));
#endif

  for (ptr = cif->arg_types, i = cif->nargs; i > 0; i--, ptr++)
    {

      /* Initialize any uninitialized aggregate type definitions */
      if (((*ptr)->size == 0) && (initialize_aggregate((*ptr)) != FFIM_OK))
	return FFIM_BAD_TYPEDEF;

      /* Perform a sanity check on the argument type, do this
	 check after the initialization.  */
      FFI_ASSERT_VALID_TYPE(*ptr);

#if !defined X86_ANY && !defined S390 && !defined PA
#ifdef SPARC
      if (((*ptr)->type == FFIM_TYPE_STRUCT
	   && ((*ptr)->size > 16 || cif->abi != FFI_V9))
	  || ((*ptr)->type == FFIM_TYPE_LONGDOUBLE
	      && cif->abi != FFI_V9))
	bytes += sizeof(void*);
      else
#endif
	{
	  /* Add any padding if necessary */
	  if (((*ptr)->alignment - 1) & bytes)
	    bytes = (unsigned)ALIGN(bytes, (*ptr)->alignment);

#ifdef TILE
	  if (bytes < 10 * FFIM_SIZEOF_ARG &&
	      bytes + STACK_ARG_SIZE((*ptr)->size) > 10 * FFIM_SIZEOF_ARG)
	    {
	      /* An argument is never split between the 10 parameter
		 registers and the stack.  */
	      bytes = 10 * FFIM_SIZEOF_ARG;
	    }
#endif
#ifdef XTENSA
	  if (bytes <= 6*4 && bytes + STACK_ARG_SIZE((*ptr)->size) > 6*4)
	    bytes = 6*4;
#endif

	  bytes += STACK_ARG_SIZE((*ptr)->size);
	}
#endif
    }

  cif->bytes = bytes;

  /* Perform machine dependent cif processing */
#ifdef FFI_TARGET_SPECIFIC_VARIADIC
  if (isvariadic)
	return ffi_mini_prep_cif_machdep_var(cif, nfixedargs, ntotalargs);
#endif

  return ffi_mini_prep_cif_machdep(cif);
}
#endif /* not __CRIS__ */

ffim_status ffi_mini_prep_cif(ffim_cif *cif, ffim_abi abi, unsigned int nargs,
			     ffim_type *rtype, ffim_type **atypes)
{
  return ffi_mini_prep_cif_core(cif, abi, 0, nargs, nargs, rtype, atypes);
}

ffim_status ffi_mini_prep_cif_var(ffim_cif *cif,
                            ffim_abi abi,
                            unsigned int nfixedargs,
                            unsigned int ntotalargs,
                            ffim_type *rtype,
                            ffim_type **atypes)
{
  return ffi_mini_prep_cif_core(cif, abi, 1, nfixedargs, ntotalargs, rtype, atypes);
}
