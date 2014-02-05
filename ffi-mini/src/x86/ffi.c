/* -----------------------------------------------------------------------
   ffi.c - Copyright (c) 1996, 1998, 1999, 2001, 2007, 2008  Red Hat, Inc.
           Copyright (c) 2002  Ranjit Mathew
           Copyright (c) 2002  Bo Thorsen
           Copyright (c) 2002  Roger Sayle
           Copyright (C) 2008, 2010  Free Software Foundation, Inc.

   x86 Foreign Function Interface

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

#if defined (__i386__) && !defined(__x86_64__)

/* ffi_mini_prep_args is called by the assembly routine once stack space
   has been allocated for the function's arguments */

void ffi_mini_prep_args(char *stack, extended_cif *ecif);
void ffi_mini_prep_args(char *stack, extended_cif *ecif)
{
  register unsigned int i;
  register void **p_argv;
  register char *argp;
  register ffim_type **p_arg;
#ifdef X86_WIN32
  size_t p_stack_args[2];
  void *p_stack_data[2];
  char *argp2 = stack;
  int stack_args_count = 0;
  int cabi = ecif->cif->abi;
#endif

  argp = stack;

  if ((ecif->cif->flags == FFIM_TYPE_STRUCT
       || ecif->cif->flags == FFIM_TYPE_MS_STRUCT)
#ifdef X86_WIN64
      && (ecif->cif->rtype->size != 1 && ecif->cif->rtype->size != 2
          && ecif->cif->rtype->size != 4 && ecif->cif->rtype->size != 8)
#endif
      )
    {
      *(void **) argp = ecif->rvalue;
#ifdef X86_WIN32
      /* For fastcall/thiscall this is first register-passed
         argument.  */
      if (cabi == FFI_THISCALL || cabi == FFI_FASTCALL)
	{
	  p_stack_args[stack_args_count] = sizeof (void*);
	  p_stack_data[stack_args_count] = argp;
	  ++stack_args_count;
	}
#endif
      argp += sizeof(void*);
    }

  p_argv = ecif->avalue;

  for (i = ecif->cif->nargs, p_arg = ecif->cif->arg_types;
       i != 0;
       i--, p_arg++)
    {
      size_t z;

      /* Align if necessary */
      if ((sizeof(void*) - 1) & (size_t) argp)
        argp = (char *) ALIGN(argp, sizeof(void*));

      z = (*p_arg)->size;
#ifdef X86_WIN64
      if (z > sizeof(ffim_arg)
          || ((*p_arg)->type == FFIM_TYPE_STRUCT
              && (z != 1 && z != 2 && z != 4 && z != 8))
#if FFIM_TYPE_DOUBLE != FFIM_TYPE_LONGDOUBLE
          || ((*p_arg)->type == FFIM_TYPE_LONGDOUBLE)
#endif
          )
        {
          z = sizeof(ffim_arg);
          *(void **)argp = *p_argv;
        }
      else if ((*p_arg)->type == FFIM_TYPE_FLOAT)
        {
          memcpy(argp, *p_argv, z);
        }
      else
#endif
      if (z < sizeof(ffim_arg))
        {
          z = sizeof(ffim_arg);
          switch ((*p_arg)->type)
            {
            case FFIM_TYPE_SINT8:
              *(ffim_sarg *) argp = (ffim_sarg)*(SINT8 *)(* p_argv);
              break;

            case FFIM_TYPE_UINT8:
              *(ffim_arg *) argp = (ffim_arg)*(UINT8 *)(* p_argv);
              break;

            case FFIM_TYPE_SINT16:
              *(ffim_sarg *) argp = (ffim_sarg)*(SINT16 *)(* p_argv);
              break;

            case FFIM_TYPE_UINT16:
              *(ffim_arg *) argp = (ffim_arg)*(UINT16 *)(* p_argv);
              break;

            case FFIM_TYPE_SINT32:
              *(ffim_sarg *) argp = (ffim_sarg)*(SINT32 *)(* p_argv);
              break;

            case FFIM_TYPE_UINT32:
              *(ffim_arg *) argp = (ffim_arg)*(UINT32 *)(* p_argv);
              break;

            case FFIM_TYPE_STRUCT:
              *(ffim_arg *) argp = *(ffim_arg *)(* p_argv);
              break;

            default:
              FFI_ASSERT(0);
            }
        }
      else
        {
          memcpy(argp, *p_argv, z);
        }

#ifdef X86_WIN32
    /* For thiscall/fastcall convention register-passed arguments
       are the first two none-floating-point arguments with a size
       smaller or equal to sizeof (void*).  */
    if ((cabi == FFI_THISCALL && stack_args_count < 1)
        || (cabi == FFI_FASTCALL && stack_args_count < 2))
      {
	if (z <= 4
	    && ((*p_arg)->type != FFIM_TYPE_FLOAT
	        && (*p_arg)->type != FFIM_TYPE_STRUCT))
	  {
	    p_stack_args[stack_args_count] = z;
	    p_stack_data[stack_args_count] = argp;
	    ++stack_args_count;
	  }
      }
#endif
      p_argv++;
#ifdef X86_WIN64
      argp += (z + sizeof(void*) - 1) & ~(sizeof(void*) - 1);
#else
      argp += z;
#endif
    }

#ifdef X86_WIN32
  /* We need to move the register-passed arguments for thiscall/fastcall
     on top of stack, so that those can be moved to registers ecx/edx by
     call-handler.  */
  if (stack_args_count > 0)
    {
      size_t zz = (p_stack_args[0] + 3) & ~3;
      char *h;

      /* Move first argument to top-stack position.  */
      if (p_stack_data[0] != argp2)
	{
	  h = alloca (zz + 1);
	  memcpy (h, p_stack_data[0], zz);
	  memmove (argp2 + zz, argp2,
	           (size_t) ((char *) p_stack_data[0] - (char*)argp2));
	  memcpy (argp2, h, zz);
	}

      argp2 += zz;
      --stack_args_count;
      if (zz > 4)
	stack_args_count = 0;

      /* If we have a second argument, then move it on top
         after the first one.  */
      if (stack_args_count > 0 && p_stack_data[1] != argp2)
	{
	  zz = p_stack_args[1];
	  zz = (zz + 3) & ~3;
	  h = alloca (zz + 1);
	  h = alloca (zz + 1);
	  memcpy (h, p_stack_data[1], zz);
	  memmove (argp2 + zz, argp2, (size_t) ((char*) p_stack_data[1] - (char*)argp2));
	  memcpy (argp2, h, zz);
	}
    }
#endif
  return;
}

/* Perform machine dependent cif processing */
ffim_status ffi_mini_prep_cif_machdep(ffim_cif *cif)
{
  unsigned int i;
  ffim_type **ptr;

  /* Set the return type flag */
  switch (cif->rtype->type)
    {
    case FFIM_TYPE_VOID:
    case FFIM_TYPE_UINT8:
    case FFIM_TYPE_UINT16:
    case FFIM_TYPE_SINT8:
    case FFIM_TYPE_SINT16:
#ifdef X86_WIN64
    case FFIM_TYPE_UINT32:
    case FFIM_TYPE_SINT32:
#endif
    case FFIM_TYPE_SINT64:
    case FFIM_TYPE_FLOAT:
    case FFIM_TYPE_DOUBLE:
#ifndef X86_WIN64
#if FFIM_TYPE_DOUBLE != FFIM_TYPE_LONGDOUBLE
    case FFIM_TYPE_LONGDOUBLE:
#endif
#endif
      cif->flags = (unsigned) cif->rtype->type;
      break;

    case FFIM_TYPE_UINT64:
#ifdef X86_WIN64
    case FFIM_TYPE_POINTER:
#endif
      cif->flags = FFIM_TYPE_SINT64;
      break;

    case FFIM_TYPE_STRUCT:
#ifndef X86
      if (cif->rtype->size == 1)
        {
          cif->flags = FFIM_TYPE_SMALL_STRUCT_1B; /* same as char size */
        }
      else if (cif->rtype->size == 2)
        {
          cif->flags = FFIM_TYPE_SMALL_STRUCT_2B; /* same as short size */
        }
      else if (cif->rtype->size == 4)
        {
#ifdef X86_WIN64
          cif->flags = FFIM_TYPE_SMALL_STRUCT_4B;
#else
          cif->flags = FFIM_TYPE_INT; /* same as int type */
#endif
        }
      else if (cif->rtype->size == 8)
        {
          cif->flags = FFIM_TYPE_SINT64; /* same as int64 type */
        }
      else
#endif
        {
#ifdef X86_WIN32
          if (cif->abi == FFI_MS_CDECL)
            cif->flags = FFIM_TYPE_MS_STRUCT;
          else
#endif
            cif->flags = FFIM_TYPE_STRUCT;
          /* allocate space for return value pointer */
          cif->bytes += ALIGN(sizeof(void*), FFIM_SIZEOF_ARG);
        }
      break;

    default:
#ifdef X86_WIN64
      cif->flags = FFIM_TYPE_SINT64;
      break;
    case FFIM_TYPE_INT:
      cif->flags = FFIM_TYPE_SINT32;
#else
      cif->flags = FFIM_TYPE_INT;
#endif
      break;
    }

  for (ptr = cif->arg_types, i = cif->nargs; i > 0; i--, ptr++)
    {
      if (((*ptr)->alignment - 1) & cif->bytes)
        cif->bytes = ALIGN(cif->bytes, (*ptr)->alignment);
      cif->bytes += ALIGN((*ptr)->size, FFIM_SIZEOF_ARG);
    }

#ifdef X86_WIN64
  /* ensure space for storing four registers */
  cif->bytes += 4 * sizeof(ffim_arg);
#endif

#ifndef X86_WIN32
  cif->bytes = (cif->bytes + 15) & ~0xF;
#endif

  return FFIM_OK;
}

extern void ffi_mini_call_SYSV(void (*)(char *, extended_cif *), extended_cif *,
                               unsigned, unsigned, unsigned *, void (*fn)(void));

void ffi_mini_call(ffim_cif *cif, void (*fn)(void), void *rvalue, void **avalue)
{
  extended_cif ecif;

  ecif.cif = cif;
  ecif.avalue = avalue;
  
  /* If the return value is a struct and we don't have a return */
  /* value address then we need to make one                     */

  if (rvalue == NULL
      && (cif->flags == FFIM_TYPE_STRUCT
          || cif->flags == FFIM_TYPE_MS_STRUCT))
    {
      ecif.rvalue = alloca(cif->rtype->size);
    }
  else
    ecif.rvalue = rvalue;
    
  
  switch (cif->abi) 
    {
    case FFIM_SYSV:
      ffi_mini_call_SYSV(ffi_mini_prep_args, &ecif, cif->bytes, cif->flags, ecif.rvalue,
                    fn);
      break;
    default:
      FFI_ASSERT(0);
      break;
    }
}

#endif /* defined (__i386__) && !defined(__x86_64__) */
