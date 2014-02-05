/* -----------------------------------------------------------------------
   ffi.c - Copyright (c) 2011 Timothy Wall
           Copyright (c) 2011 Plausible Labs Cooperative, Inc.
           Copyright (c) 2011 Anthony Green
	   Copyright (c) 2011 Free Software Foundation
           Copyright (c) 1998, 2008, 2011  Red Hat, Inc.

   ARM Foreign Function Interface

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

#ifdef __arm__

/* Forward declares. */
static int vfp_type_p (ffim_type *);
static void layout_vfp_args (ffim_cif *);

/* Used in assembly. */
int ffi_mini_prep_args_SYSV(char *stack, extended_cif *ecif, float *vfp_space);
int ffi_mini_prep_args_VFP(char *stack, extended_cif *ecif, float *vfp_space);

static char* ffi_align(ffim_type **p_arg, char *argp)
{
  /* Align if necessary */
  register size_t alignment = (*p_arg)->alignment;
  if (alignment < 4)
  {
    alignment = 4;
  }
#ifdef _WIN32_WCE
  if (alignment > 4)
  {
    alignment = 4;
  }
#endif
  if ((alignment - 1) & (unsigned) argp)
  {
    argp = (char *) ALIGN(argp, alignment);
  }

  if ((*p_arg)->type == FFIM_TYPE_STRUCT)
  {
    argp = (char *) ALIGN(argp, 4);
  }
  return argp;
}

static size_t ffi_put_arg(ffim_type **arg_type, void **arg, char *stack)
{
	register char* argp = stack;
	register ffim_type **p_arg = arg_type;
	register void **p_argv = arg;
	register size_t z = (*p_arg)->size;
  if (z < sizeof(int))
    {
		z = sizeof(int);
		switch ((*p_arg)->type)
      {
      case FFIM_TYPE_SINT8:
        *(signed int *) argp = (signed int)*(SINT8 *)(* p_argv);
        break;
        
      case FFIM_TYPE_UINT8:
        *(unsigned int *) argp = (unsigned int)*(UINT8 *)(* p_argv);
        break;
        
      case FFIM_TYPE_SINT16:
        *(signed int *) argp = (signed int)*(SINT16 *)(* p_argv);
        break;
        
      case FFIM_TYPE_UINT16:
        *(unsigned int *) argp = (unsigned int)*(UINT16 *)(* p_argv);
        break;
        
      case FFIM_TYPE_STRUCT:
        memcpy(argp, *p_argv, (*p_arg)->size);
        break;

      default:
        FFI_ASSERT(0);
      }
    }
  else if (z == sizeof(int))
    {
		if ((*p_arg)->type == FFIM_TYPE_FLOAT)
			*(float *) argp = *(float *)(* p_argv);
		else
			*(unsigned int *) argp = (unsigned int)*(UINT32 *)(* p_argv);
    }
	else if (z == sizeof(double) && (*p_arg)->type == FFIM_TYPE_DOUBLE)
		{
			*(double *) argp = *(double *)(* p_argv);
		}
  else
    {
      memcpy(argp, *p_argv, z);
    }
  return z;
}
/* ffi_mini_prep_args is called by the assembly routine once stack space
   has been allocated for the function's arguments
   
   The vfp_space parameter is the load area for VFP regs, the return
   value is cif->vfp_used (word bitset of VFP regs used for passing
   arguments). These are only used for the VFP hard-float ABI.
*/
int ffi_mini_prep_args_SYSV(char *stack, extended_cif *ecif, float *vfp_space)
{
  register unsigned int i;
  register void **p_argv;
  register char *argp;
  register ffim_type **p_arg;
  argp = stack;
  

  if ( ecif->cif->flags == FFIM_TYPE_STRUCT ) {
    *(void **) argp = ecif->rvalue;
    argp += 4;
  }

  p_argv = ecif->avalue;

  for (i = ecif->cif->nargs, p_arg = ecif->cif->arg_types;
       (i != 0);
       i--, p_arg++, p_argv++)
    {
    argp = ffi_align(p_arg, argp);
    argp += ffi_put_arg(p_arg, p_argv, argp);
    }

  return 0;
}

int ffi_mini_prep_args_VFP(char *stack, extended_cif *ecif, float *vfp_space)
{
  // make sure we are using FFIM_VFP
  FFI_ASSERT(ecif->cif->abi == FFIM_VFP);

  register unsigned int i, vi = 0;
  register void **p_argv;
  register char *argp, *regp, *eo_regp;
  register ffim_type **p_arg;
  char stack_used = 0;
  char done_with_regs = 0;
  char is_vfp_type;

  /* the first 4 words on the stack are used for values passed in core
   * registers. */
  regp = stack;
  eo_regp = argp = regp + 16;
  

  /* if the function returns an FFIM_TYPE_STRUCT in memory, that address is
   * passed in r0 to the function */
  if ( ecif->cif->flags == FFIM_TYPE_STRUCT ) {
    *(void **) regp = ecif->rvalue;
    regp += 4;
  }

  p_argv = ecif->avalue;

  for (i = ecif->cif->nargs, p_arg = ecif->cif->arg_types;
       (i != 0);
       i--, p_arg++, p_argv++)
    {
      is_vfp_type = vfp_type_p (*p_arg);

      /* Allocated in VFP registers. */
      if(vi < ecif->cif->vfp_nargs && is_vfp_type)
        {
          char *vfp_slot = (char *)(vfp_space + ecif->cif->vfp_args[vi++]);
          ffi_put_arg(p_arg, p_argv, vfp_slot);
          continue;
        }
      /* Try allocating in core registers. */
      else if (!done_with_regs && !is_vfp_type)
        {
          char *tregp = ffi_align(p_arg, regp);
          size_t size = (*p_arg)->size; 
          size = (size < 4)? 4 : size; // pad
          /* Check if there is space left in the aligned register area to place
           * the argument */
          if(tregp + size <= eo_regp)
            {
              regp = tregp + ffi_put_arg(p_arg, p_argv, tregp);
              done_with_regs = (regp == argp);
              // ensure we did not write into the stack area
              FFI_ASSERT(regp <= argp);
              continue;
            }
          /* In case there are no arguments in the stack area yet, 
          the argument is passed in the remaining core registers and on the
          stack. */
          else if (!stack_used) 
            {
              stack_used = 1;
              done_with_regs = 1;
              argp = tregp + ffi_put_arg(p_arg, p_argv, tregp);
              FFI_ASSERT(eo_regp < argp);
              continue;
            }
        }
      /* Base case, arguments are passed on the stack */
      stack_used = 1;
      argp = ffi_align(p_arg, argp);
      argp += ffi_put_arg(p_arg, p_argv, argp);
    }
  /* Indicate the VFP registers used. */
  return ecif->cif->vfp_used;
}

/* Perform machine dependent cif processing */
ffim_status ffi_mini_prep_cif_machdep(ffim_cif *cif)
{
  int type_code;
  /* Round the stack up to a multiple of 8 bytes.  This isn't needed 
     everywhere, but it is on some platforms, and it doesn't harm anything
     when it isn't needed.  */
  cif->bytes = (cif->bytes + 7) & ~7;

  /* Set the return type flag */
  switch (cif->rtype->type)
    {
    case FFIM_TYPE_VOID:
    case FFIM_TYPE_FLOAT:
    case FFIM_TYPE_DOUBLE:
      cif->flags = (unsigned) cif->rtype->type;
      break;

    case FFIM_TYPE_SINT64:
    case FFIM_TYPE_UINT64:
      cif->flags = (unsigned) FFIM_TYPE_SINT64;
      break;

    case FFIM_TYPE_STRUCT:
      if (cif->abi == FFIM_VFP
	  && (type_code = vfp_type_p (cif->rtype)) != 0)
	{
	  /* A Composite Type passed in VFP registers, either
	     FFIM_TYPE_STRUCT_VFP_FLOAT or FFIM_TYPE_STRUCT_VFP_DOUBLE. */
	  cif->flags = (unsigned) type_code;
	}
      else if (cif->rtype->size <= 4)
	/* A Composite Type not larger than 4 bytes is returned in r0.  */
	cif->flags = (unsigned)FFIM_TYPE_INT;
      else
	/* A Composite Type larger than 4 bytes, or whose size cannot
	   be determined statically ... is stored in memory at an
	   address passed [in r0].  */
	cif->flags = (unsigned)FFIM_TYPE_STRUCT;
      break;

    default:
      cif->flags = FFIM_TYPE_INT;
      break;
    }

  /* Map out the register placements of VFP register args.
     The VFP hard-float calling conventions are slightly more sophisticated than
     the base calling conventions, so we do it here instead of in ffi_mini_prep_args(). */
  if (cif->abi == FFIM_VFP)
    layout_vfp_args (cif);

  return FFIM_OK;
}

/* Perform machine dependent cif processing for variadic calls */
ffim_status ffi_mini_prep_cif_machdep_var(ffim_cif *cif,
				    unsigned int nfixedargs,
				    unsigned int ntotalargs)
{
  /* VFP variadic calls actually use the SYSV ABI */
  if (cif->abi == FFIM_VFP)
	cif->abi = FFIM_SYSV;

  return ffi_mini_prep_cif_machdep(cif);
}

/* Prototypes for assembly functions, in sysv.S */
extern void ffi_mini_call_SYSV (void (*fn)(void), extended_cif *, unsigned, unsigned, unsigned *);
extern void ffi_mini_call_VFP (void (*fn)(void), extended_cif *, unsigned, unsigned, unsigned *);

void ffi_mini_call(ffim_cif *cif, void (*fn)(void), void *rvalue, void **avalue)
{
  extended_cif ecif;

  int small_struct = (cif->flags == FFIM_TYPE_INT 
		      && cif->rtype->type == FFIM_TYPE_STRUCT);
  int vfp_struct = (cif->flags == FFIM_TYPE_STRUCT_VFP_FLOAT
		    || cif->flags == FFIM_TYPE_STRUCT_VFP_DOUBLE);

  unsigned int temp;
  
  ecif.cif = cif;
  ecif.avalue = avalue;

  /* If the return value is a struct and we don't have a return	*/
  /* value address then we need to make one			*/

  if ((rvalue == NULL) && 
      (cif->flags == FFIM_TYPE_STRUCT))
    {
      ecif.rvalue = alloca(cif->rtype->size);
    }
  else if (small_struct)
    ecif.rvalue = &temp;
  else if (vfp_struct)
    {
      /* Largest case is double x 4. */
      ecif.rvalue = alloca(32);
    }
  else
    ecif.rvalue = rvalue;

  switch (cif->abi) 
    {
    case FFIM_SYSV:
      ffi_mini_call_SYSV (fn, &ecif, cif->bytes, cif->flags, ecif.rvalue);
      break;

    case FFIM_VFP:
#ifdef __ARM_EABI__
      ffi_mini_call_VFP (fn, &ecif, cif->bytes, cif->flags, ecif.rvalue);
      break;
#endif

    default:
      FFI_ASSERT(0);
      break;
    }
  if (small_struct)
    {
      FFI_ASSERT(rvalue != NULL);
      memcpy (rvalue, &temp, cif->rtype->size);
    }
    
  else if (vfp_struct)
    {
      FFI_ASSERT(rvalue != NULL);
      memcpy (rvalue, ecif.rvalue, cif->rtype->size);
    }
    
}

/** private members **/

/* Below are routines for VFP hard-float support. */

static int rec_vfp_type_p (ffim_type *t, int *elt, int *elnum)
{
  switch (t->type)
    {
    case FFIM_TYPE_FLOAT:
    case FFIM_TYPE_DOUBLE:
      *elt = (int) t->type;
      *elnum = 1;
      return 1;

    case FFIM_TYPE_STRUCT_VFP_FLOAT:
      *elt = FFIM_TYPE_FLOAT;
      *elnum = t->size / sizeof (float);
      return 1;

    case FFIM_TYPE_STRUCT_VFP_DOUBLE:
      *elt = FFIM_TYPE_DOUBLE;
      *elnum = t->size / sizeof (double);
      return 1;

    case FFIM_TYPE_STRUCT:;
      {
	int base_elt = 0, total_elnum = 0;
	ffim_type **el = t->elements;
	while (*el)
	  {
	    int el_elt = 0, el_elnum = 0;
	    if (! rec_vfp_type_p (*el, &el_elt, &el_elnum)
		|| (base_elt && base_elt != el_elt)
		|| total_elnum + el_elnum > 4)
	      return 0;
	    base_elt = el_elt;
	    total_elnum += el_elnum;
	    el++;
	  }
	*elnum = total_elnum;
	*elt = base_elt;
	return 1;
      }
    default: ;
    }
  return 0;
}

static int vfp_type_p (ffim_type *t)
{
  int elt, elnum;
  if (rec_vfp_type_p (t, &elt, &elnum))
    {
      if (t->type == FFIM_TYPE_STRUCT)
	{
	  if (elnum == 1)
	    t->type = elt;
	  else
	    t->type = (elt == FFIM_TYPE_FLOAT
		       ? FFIM_TYPE_STRUCT_VFP_FLOAT
		       : FFIM_TYPE_STRUCT_VFP_DOUBLE);
	}
      return (int) t->type;
    }
  return 0;
}

static int place_vfp_arg (ffim_cif *cif, ffim_type *t)
{
  short reg = cif->vfp_reg_free;
  int nregs = t->size / sizeof (float);
  int align = ((t->type == FFIM_TYPE_STRUCT_VFP_FLOAT
		|| t->type == FFIM_TYPE_FLOAT) ? 1 : 2);
  /* Align register number. */
  if ((reg & 1) && align == 2)
    reg++;
  while (reg + nregs <= 16)
    {
      int s, new_used = 0;
      for (s = reg; s < reg + nregs; s++)
	{
	  new_used |= (1 << s);
	  if (cif->vfp_used & (1 << s))
	    {
	      reg += align;
	      goto next_reg;
	    }
	}
      /* Found regs to allocate. */
      cif->vfp_used |= new_used;
      cif->vfp_args[cif->vfp_nargs++] = reg;

      /* Update vfp_reg_free. */
      if (cif->vfp_used & (1 << cif->vfp_reg_free))
	{
	  reg += nregs;
	  while (cif->vfp_used & (1 << reg))
	    reg += 1;
	  cif->vfp_reg_free = reg;
	}
      return 0;
    next_reg: ;
    }
  // done, mark all regs as used
  cif->vfp_reg_free = 16;
  cif->vfp_used = 0xFFFF;
  return 1;
}

static void layout_vfp_args (ffim_cif *cif)
{
  int i;
  /* Init VFP fields */
  cif->vfp_used = 0;
  cif->vfp_nargs = 0;
  cif->vfp_reg_free = 0;
  memset (cif->vfp_args, -1, 16); /* Init to -1. */

  for (i = 0; i < cif->nargs; i++)
    {
      ffim_type *t = cif->arg_types[i];
      if (vfp_type_p (t) && place_vfp_arg (cif, t) == 1)
        {
          break;
        }
    }
}


#endif
