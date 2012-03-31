/*
 * blockimp_private.h
 * blockimp
 *
 * Private Block ABI Structures
 * Originally acquired frm PLBlocks and compiler_rt
 *
 * Copyright 2008 - 2009 Apple, Inc. 
 * Copyright 2009 - 2011 Plausible Labs Cooperative, Inc.
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

#pragma once

#ifndef PL_BLOCKIMP_PRIVATE
#define PL_BLOCKIMP_PRIVATE

#include "blockimp.h"

extern void *pl_blockimp_table_page;
extern struct pl_trampoline_table_config pl_blockimp_table_page_config;

extern void *pl_blockimp_table_stret_page;
extern struct pl_trampoline_table_config pl_blockimp_table_stret_page_config;

#pragma mark Fallback Support

#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7
extern IMP imp_implementationWithBlock(id block) AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;
#else
extern IMP imp_implementationWithBlock(void *block) AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;
#endif
extern void *imp_getBlock(IMP anImp) WEAK_IMPORT_ATTRIBUTE;
extern BOOL imp_removeBlock(IMP anImp) WEAK_IMPORT_ATTRIBUTE;

/*
 * Block Flags
 */
typedef enum {
    /** 16-bit block reference count. */
    BLOCK_REFCOUNT_MASK =     (0xffff),
    
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    
    /** Helpers have C++ code. */
    BLOCK_HAS_CTOR =          (1 << 26),
    
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    
    /** Block returns its aggregate value in memory (ie, the block has a structure return type). */
    BLOCK_USE_STRET =         (1 << 29),
} block_flags_t;


/*
 * Block field flags.
 */
typedef enum {
    // see function implementation for a more complete description of these fields and combinations
    BLOCK_FIELD_IS_OBJECT   =  3,  // id, NSObject, __attribute__((NSObject)), block, ...
    BLOCK_FIELD_IS_BLOCK    =  7,  // a block variable
    BLOCK_FIELD_IS_BYREF    =  8,  // the on stack structure holding the __block variable
    BLOCK_FIELD_IS_WEAK     = 16,  // declared __weak, only used in byref copy helpers
    BLOCK_BYREF_CALLER      = 128, // called from __block (byref) copy/dispose support routines.
} block_field_flags_t;

/*
 * Block description.
 *
 * Block descriptions are shared across all instances of a block, and
 * provide basic information on the block size, as well as pointers
 * to any helper functions necessary to copy or dispose of the block.
 */
struct Block_descriptor {
    /** Reserved value */
    unsigned long int reserved;
    
    /** Total size of the described block, including imported variables. */
    unsigned long int size;
    
    /** Optional block copy helper. May be NULL. */
    void (*copy)(void *dst, void *src);
    
    /** Optional block dispose helper. May be NULL. */
    void (*dispose)(void *);
};


/*
 * Block instance.
 *
 * The block layout defines the per-block instance state, which includes
 * a reference to the shared block descriptor.
 *
 * The block's imported variables are allocated following the block
 * descriptor member.
 */
struct Block_layout {
    /** Pointer to the block's Objective-C class. */
    void *isa;
    
    /** Block flags. */
    int flags;
    
    /** Reserved value. */
    int reserved;
    
    /** Block invocation function. */
    void (*invoke)(void *, ...);
    
    /** Shared block descriptor. */
    struct Block_descriptor *descriptor;
    
    // imported variables
};

#endif /* PL_BLOCKIMP_PRIVATE */