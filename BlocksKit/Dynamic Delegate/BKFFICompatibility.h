//
//  ffi-mini-compat.h
//  BlocksKit
//
//  Created by Zach Waldowski on 12/3/13.
//  Copyright (c) 2013 Pandamonia LLC. All rights reserved.
//

#ifndef BlocksKit_FFI_h
#define BlocksKit_FFI_h

/// Use for declaring a macro-style function in a header
#if !defined(FFIM_ALWAYS_INLINE)
# if __has_attribute(always_inline) || defined(__GNUC__)
#  define FFIM_ALWAYS_INLINE static __inline__ __attribute__((always_inline))
# elif defined(__MWERKS__) || defined(__cplusplus)
#  define FFIM_ALWAYS_INLINE static inline
# elif defined(_MSC_VER)
#  define FFIM_ALWAYS_INLINE static __inline
# elif TARGET_OS_WIN32
#  define FFIM_ALWAYS_INLINE static __inline__
# endif
#endif

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <ffi/ffi.h>
#else
#import <ffi_mini.h>

typedef struct _ffim_type ffi_type;
typedef ffim_status ffi_status;
typedef FFIM_TYPE FFI_TYPE;
typedef ffim_cif ffi_cif;
typedef ffim_abi ffi_abi;

#define ffi_type_void ffim_type_void
#define ffi_type_uint8 ffim_type_uint8
#define ffi_type_sint8 ffim_type_sint8
#define ffi_type_uint16 ffim_type_uint16
#define ffi_type_sint16 ffim_type_sint16
#define ffi_type_uint32 ffim_type_uint32
#define ffi_type_sint32 ffim_type_sint32
#define ffi_type_uint64 ffim_type_uint64
#define ffi_type_sint64 ffim_type_sint64
#define ffi_type_float ffim_type_float
#define ffi_type_double ffim_type_double
#define ffi_type_pointer ffim_type_pointer
#define ffi_type_longdouble ffim_type_longdouble

#define ffi_type_uchar ffim_type_uchar
#define ffi_type_schar ffim_type_schar
#define ffi_type_ushort ffim_type_ushort
#define ffi_type_sshort ffim_type_sshort
#define ffi_type_uint ffim_type_uint
#define ffi_type_sint ffim_type_sint
#define ffi_type_ulong ffim_type_ulong
#define ffi_type_slong ffim_type_slong

#define FFI_OK FFIM_OK
#define FFI_BAD_TYPEDEF FFIM_BAD_TYPEDEF
#define FFI_BAD_ABI FFIM_BAD_ABI

#define FFI_TYPE_VOID FFIM_TYPE_VOID
#define FFI_TYPE_INT FFIM_TYPE_INT
#define FFI_TYPE_FLOAT FFIM_TYPE_FLOAT
#define FFI_TYPE_DOUBLE FFIM_TYPE_DOUBLE
#define FFI_TYPE_LONGDOUBLE FFIM_TYPE_LONGDOUBLE
#define FFI_TYPE_UINT8 FFIM_TYPE_UINT8
#define FFI_TYPE_SINT8 FFIM_TYPE_SINT8
#define FFI_TYPE_UINT16 FFIM_TYPE_UINT16
#define FFI_TYPE_SINT16 FFIM_TYPE_SINT16
#define FFI_TYPE_UINT32 FFIM_TYPE_UINT32
#define FFI_TYPE_SINT32 FFIM_TYPE_SINT32
#define FFI_TYPE_UINT64 FFIM_TYPE_UINT64
#define FFI_TYPE_SINT64 FFIM_TYPE_SINT64
#define FFI_TYPE_STRUCT FFIM_TYPE_STRUCT
#define FFI_TYPE_POINTER FFIM_TYPE_POINTER
#define FFI_TYPE_LAST FFIM_TYPE_LAST

#define FFI_DEFAULT_ABI FFIM_DEFAULT_ABI

FFIM_ALWAYS_INLINE ffi_status ffi_prep_cif(ffi_cif *cif,
                                           ffi_abi abi,
                                           unsigned int nargs,
                                           ffi_type *rtype,
                                           ffi_type **atypes)
{
    return ffi_mini_prep_cif(cif, abi, nargs, rtype, atypes);
}

FFIM_ALWAYS_INLINE ffi_status ffi_prep_cif_var(ffim_cif *cif,
                                  ffim_abi abi,
                                  unsigned int nfixedargs,
                                  unsigned int ntotalargs,
                                  ffim_type *rtype,
                                  ffim_type **atypes)
{
    return ffi_mini_prep_cif_var(cif, abi, nfixedargs, ntotalargs, rtype, atypes);
}

FFIM_ALWAYS_INLINE void ffi_call(ffi_cif *cif,
                   void (*fn)(void),
                   void *rvalue,
                   void **avalue)
{
    return ffi_mini_call(cif, fn, rvalue, avalue);
}

#endif
#endif
