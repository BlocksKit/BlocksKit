/*
 * blockimp.c
 * blockimp
 *
 * Author: Landon Fuller <landonf@plausible.coop>
 *
 * Copyright 2010-2011 Plausible Labs Cooperative, Inc.
 * All rights reserved.
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

#include "blockimp.h"
#include "blockimp_private.h"
#include "blockimp_trampoline_table.h"

#include <stdio.h>
#include <Block.h>
#include <pthread.h>

#pragma mark Trampolines

/* Global lock for our mutable state. Must be held when accessing the trampoline tables. */
static pthread_mutex_t blockimp_lock = PTHREAD_MUTEX_INITIALIZER;

/* Trampoline tables for objc_msgSend_stret() dispatch. */
static pl_trampoline_table *blockimp_table_stret = NULL;

/* Trampoline tables for objc_msgSend() dispatch. */
static pl_trampoline_table *blockimp_table = NULL;

/**
 * 
 */
IMP pl_imp_implementationWithBlock (id block) {
    /* Prefer Apple's implementation */
	if (&imp_implementationWithBlock != NULL) {
		block = [[block copy] autorelease];
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7
		return imp_implementationWithBlock( block );
#else
		return imp_implementationWithBlock( (void *) block );
#endif
	}

    /* Allocate the appropriate trampoline type. */
    pl_trampoline *tramp;
    struct Block_layout *bl = (void *)block;
    if (bl->flags & BLOCK_USE_STRET) {
        tramp = pl_trampoline_alloc(&pl_blockimp_table_stret_page_config, &blockimp_lock, &blockimp_table_stret);
    } else {
        tramp = pl_trampoline_alloc(&pl_blockimp_table_page_config, &blockimp_lock, &blockimp_table);
    }
    
    /* Configure the trampoline */
    void **config = pl_trampoline_data_ptr(tramp->trampoline);
    config[0] = Block_copy(block);
    config[1] = tramp;

    /* Return the function pointer. */
    return (IMP) tramp->trampoline;
}

/**
 *
 */
void *pl_imp_getBlock(IMP anImp) {
    /* Prefer Apple's implementation */
    if (&imp_getBlock != NULL) {
        return imp_getBlock(anImp);
    }

    /* Fetch the config data and return the block reference. */
    void **config = pl_trampoline_data_ptr(anImp);
    return config[0];
}

/**
 *
 */
BOOL pl_imp_removeBlock(IMP anImp) {
    /* Prefer Apple's implementation */
    if (&imp_removeBlock != NULL)
        return imp_removeBlock(anImp);
    
    /* Fetch the config data */
    void **config = pl_trampoline_data_ptr(anImp);
    struct Block_layout *bl = config[0];
    pl_trampoline *tramp = config[1];

    /* Drop the trampoline allocation */
    if (bl->flags & BLOCK_USE_STRET) {
        pl_trampoline_free(&blockimp_lock, &blockimp_table_stret, tramp);
    } else {
        pl_trampoline_free(&blockimp_lock, &blockimp_table, tramp);
    }

    /* Release the block */
    Block_release(config[0]);

    // TODO - what does this return value mean?
    return YES;
}