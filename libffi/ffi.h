#ifdef __arm__
#include "ffi_arm.h"
#elif defined(__x86_64__)
#include "ffi_x86-64.h"
#elif defined(__i386__)
#include "ffi_i386.h"
#else
#error Not supported. 
#endif
