/*	Manually created fficonfig.h for Darwin.

	This file is manually generated to do away with the need for autoconf and
	therefore make it easier to cross-compile and build fat binaries.
*/

#if defined(__APPLE__) && defined(__MACH__) && !defined(MACOSX)
# define MACOSX
#endif

#ifndef MACOSX
# error "This file is only supported on OS X or iOS."
#endif

#ifndef LIBFFI_CONFIG_MINI_H
#define LIBFFI_CONFIG_MINI_H

#if defined(__i386__)
# undef FFI_EXEC_TRAMPOLINE_TABLE
# define FFI_MMAP_EXEC_WRIT 1
# undef WORDS_BIGENDIAN
# define SIZEOF_DOUBLE 8
# define HAVE_LONG_DOUBLE 1
# define SIZEOF_LONG_DOUBLE 16
# define X86_DARWIN
#elif defined(__x86_64__)
# undef FFI_EXEC_TRAMPOLINE_TABLE
# define FFI_MMAP_EXEC_WRIT 1
# undef WORDS_BIGENDIAN
# define SIZEOF_DOUBLE 8
# define HAVE_LONG_DOUBLE 1
# define SIZEOF_LONG_DOUBLE 16
# define X86_DARWIN
#elif defined(__arm__)
# define FFI_EXEC_TRAMPOLINE_TABLE 1
# undef FFI_MMAP_EXEC_WRIT
# undef WORDS_BIGENDIAN
# define SIZEOF_DOUBLE 8
# undef HAVE_LONG_DOUBLE
# define SIZEOF_LONG_DOUBLE 8
# define ARM
#elif defined(__arm64__)
# undef FFI_EXEC_TRAMPOLINE_TABLE
# define FFI_MMAP_EXEC_WRIT 1
# undef WORDS_BIGENDIAN
# define SIZEOF_DOUBLE 8
# undef HAVE_LONG_DOUBLE
# define SIZEOF_LONG_DOUBLE 8
# define AARCH64
#else
#error "Unknown Darwin CPU type"
#endif

#define EH_FRAME_FLAGS "aw"
#define FFI_NO_RAW_API 1
#define HAVE_ALLOCA 1
#define HAVE_ALLOCA_H 1
#define HAVE_AS_CFI_PSEUDO_OP 1
#define HAVE_DLFCN_H 1
#define HAVE_HIDDEN_VISIBILITY_ATTRIBUTE 1
#define HAVE_INTTYPES_H 1
#define HAVE_MEMCPY 1
#define HAVE_MEMORY_H 1
#define HAVE_MMAP 1
#define HAVE_MMAP_ANON 1
#define HAVE_MMAP_FILE 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_MMAN_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1
#define STDC_HEADERS 1

#define PACKAGE "libffi"
#define PACKAGE_BUGREPORT "http://github.com/atgreen/libffi/issues"
#define PACKAGE_NAME "libffi"
#define PACKAGE_STRING "libffi 3.0.14-rc0-mini"
#define PACKAGE_TARNAME "libffi"
#define PACKAGE_VERSION "3.0.14-rc0-mini"
#define VERSION "3.0.14-rc0-mini"

#ifdef HAVE_HIDDEN_VISIBILITY_ATTRIBUTE
# ifdef LIBFFI_ASM
#  define FFI_HIDDEN(name) .hidden name
# else
#  define FFI_HIDDEN __attribute__ ((visibility ("hidden")))
# endif
#else
# ifdef LIBFFI_ASM
#  define FFI_HIDDEN(name)
# else
#  define FFI_HIDDEN
# endif
#endif

#endif
