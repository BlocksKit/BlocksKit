//
//  A2BlockImplementation.m
//  A2DynamicDelegate
//
//  Created by Landon Fuller <landonf@plausible.coop>.
//  Copyright (c) 2010-2011 Plausible Labs Cooperative, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge,
//  to any person obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to permit
//  persons to whom the Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#include "A2BlockImplementation.h"
#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <pthread.h>

#pragma mark - Block Internals

typedef enum {
    BLOCK_DEALLOCATING =      (0x0001),
    BLOCK_REFCOUNT_MASK =     (0xfffe),
    BLOCK_NEEDS_FREE =        (1 << 24),
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GC =             (1 << 27),
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_USE_STRET =         (1 << 29), // undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30)
} block_flags_t;

typedef enum {
    // see function implementation for a more complete description of these fields and combinations
    BLOCK_FIELD_IS_OBJECT   =  3,  // id, NSObject, __attribute__((NSObject)), block, ...
    BLOCK_FIELD_IS_BLOCK    =  7,  // a block variable
    BLOCK_FIELD_IS_BYREF    =  8,  // the on stack structure holding the __block variable
    BLOCK_FIELD_IS_WEAK     = 16,  // declared __weak, only used in byref copy helpers
    BLOCK_BYREF_CALLER      = 128, // called from __block (byref) copy/dispose support routines.
} block_field_flags_t;

struct Block_descriptor_1 {
	unsigned long int reserved;
	unsigned long int size;
};

struct Block_descriptor_2 {
// requires BLOCK_HAS_COPY_DISPOSE
	void (*copy)(void *dst, const void *src);
	void (*dispose)(const void *);
};

struct Block_descriptor_3 {
// requires BLOCK_HAS_SIGNATURE
	const char *signature;
	const char *layout;
};

struct Block {
	void *isa;
	block_flags_t flags;
	int reserved; 
	void (*invoke)(void *, ...);
	struct Block_descriptor_1 *descriptor;
	// imported variables
};

typedef struct Block *BlockRef;

BOOL a2_blockHasSignature(id block) {
	return a2_blockGetSignature(block) ? YES : NO;
}

BOOL a2_blockHasStret(id block) {
    BlockRef layout = (BlockRef)block;
    int requiredFlags = BLOCK_HAS_SIGNATURE | BLOCK_USE_STRET;
    return (layout->flags & requiredFlags) == requiredFlags;
}

const char *a2_blockGetSignature(id block) {
	BlockRef layout = (BlockRef)block;
	
	int requiredFlags = BLOCK_HAS_SIGNATURE;
    if ((layout->flags & requiredFlags) != requiredFlags)
		return NULL;
	
    uint8_t *desc = (uint8_t *)layout->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE)
        desc += sizeof(struct Block_descriptor_2);
	struct Block_descriptor_3 *desc3 = (struct Block_descriptor_3 *)desc;
    if (!desc3)
		return NULL;
    return desc3->signature;
}

void *a2_blockGetImplementation(id block) {
	BlockRef aBlock = (BlockRef)block;
    return aBlock->invoke;
}

#pragma mark - Structure declarations

/*
 * Trampoline table configuration
 */
typedef struct _pl_trampoline_table_config {
uint32_t trampoline_size;
uint32_t page_offset;
uint32_t trampoline_count;
void *template_page;
} pl_trampoline_table_config;

/*
 * A linked list of trampoline table entries.
 */
typedef struct _pl_trampoline {
/* The actual trampoline. */
void *(*trampoline)();

/** The table in which the entry is allocated. */
struct _pl_trampoline_table *table;

/* Next entry in the trampoline list. */
struct _pl_trampoline *next;
} pl_trampoline;

/*
 * A double-linked list of trampoline table entries.
 */
typedef struct _pl_trampoline_table {
/* Table configuration */
pl_trampoline_table_config *config;

/* Contigious writable and executable pages */
vm_address_t data_page;
vm_address_t trampoline_page;

/* free list tracking */
uint16_t free_count;
pl_trampoline *free_list;
pl_trampoline *free_list_pool;

struct _pl_trampoline_table *prev;
struct _pl_trampoline_table *next;
} pl_trampoline_table;

#pragma mark - Function declarations

extern void *pl_blockimp_table_page;
extern void *pl_blockimp_table_stret_page;

#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7
extern IMP imp_implementationWithBlock(id block) AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;
#else
extern IMP imp_implementationWithBlock(void *block) AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;
#endif
extern void *imp_getBlock(IMP anImp) WEAK_IMPORT_ATTRIBUTE;
extern BOOL imp_removeBlock(IMP anImp) WEAK_IMPORT_ATTRIBUTE;

#pragma mark - Arch configuration

#if defined(__i386__)

pl_trampoline_table_config pl_blockimp_table_page_config = {
	.trampoline_size = 8,
	.page_offset = 32,
	.trampoline_count = 508,
	.template_page = &pl_blockimp_table_page
};

pl_trampoline_table_config pl_blockimp_table_stret_page_config = {
	.trampoline_size = 8,
	.page_offset = 32,
	.trampoline_count = 508,
	.template_page = &pl_blockimp_table_stret_page
};

#elif defined(__x86_64__)

pl_trampoline_table_config pl_blockimp_table_page_config = {
	.trampoline_size = 16,
	.page_offset = 32,
	.trampoline_count = 254,
	.template_page = &pl_blockimp_table_page
};

pl_trampoline_table_config pl_blockimp_table_stret_page_config = {
	.trampoline_size = 16,
	.page_offset = 32,
	.trampoline_count = 254,
	.template_page = &pl_blockimp_table_stret_page
};

#elif defined(__arm__)

pl_trampoline_table_config pl_blockimp_table_page_config = {
	.trampoline_size = 8,
	.page_offset = 20,
	.trampoline_count = 509,
	.template_page = &pl_blockimp_table_page
};

pl_trampoline_table_config pl_blockimp_table_stret_page_config = {
	.trampoline_size = 8,
	.page_offset = 20,
	.trampoline_count = 509,
	.template_page = &pl_blockimp_table_stret_page
};

#else
#error Unknown Architecture
#endif

#pragma mark - Private functions

/*
 * Allocate, register, and return a new trampoline table. The trampoline lock must be held by the caller.
 *
 * @param source_page The source page that will be remapped.
 */
static pl_trampoline_table *pl_trampoline_table_alloc (pl_trampoline_table_config *config) {
    pl_trampoline_table *table = NULL;
    
    /* Loop until we can allocate two contigious pages */
    while (table == NULL) {
        vm_address_t data_page = 0x0;
        kern_return_t kt;
        
        /* Try to allocate two pages */
        kt = vm_allocate (mach_task_self(), &data_page, PAGE_SIZE*2, VM_FLAGS_ANYWHERE);
        if (kt != KERN_SUCCESS) {
            fprintf(stderr, "vm_allocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            break;
        }
        
        /* Now drop the second half of the allocation to make room for the trampoline table */
        vm_address_t trampoline_page = data_page+PAGE_SIZE;
        kt = vm_deallocate (mach_task_self(), trampoline_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS) {
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            break;
        }
        
        /* Remap the trampoline table to directly follow the config page */
        vm_prot_t cur_prot;
        vm_prot_t max_prot;
        
        kt = vm_remap (mach_task_self(), &trampoline_page, PAGE_SIZE, 0x0, FALSE, mach_task_self(), (vm_address_t) config->template_page, FALSE, &cur_prot, &max_prot, VM_INHERIT_SHARE);
        
        /* If we lost access to the destination trampoline page, drop our config allocation mapping and retry */
        if (kt != KERN_SUCCESS) {
            /* Log unexpected failures */
            if (kt != KERN_NO_SPACE) {
                fprintf(stderr, "vm_remap() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
            }
            
            vm_deallocate (mach_task_self(), data_page, PAGE_SIZE);
            continue;
        }
        
        /* We have valid trampoline and config pages */
        table = calloc (1, sizeof(pl_trampoline_table));
        table->free_count = config->trampoline_count;
        table->data_page = data_page;
        table->trampoline_page = trampoline_page;
        table->config = config;
		
        /* Create and initialize the free list */
        table->free_list_pool = calloc(config->trampoline_count, sizeof(pl_trampoline));
        
        uint16_t i;
        for (i = 0; i < table->free_count; i++) {
            pl_trampoline *entry = &table->free_list_pool[i];
            entry->table = table;
            entry->trampoline = (void *) (table->trampoline_page + (i * config->trampoline_size) + config->page_offset);
			
            if (i < table->free_count - 1)
                entry->next = &table->free_list_pool[i+1];
        }
        
        table->free_list = table->free_list_pool;
    }
    
    return table;
}

/**
 * Allocate a new trampoline. Returns NULL on error.
 *
 * @param config The table configuration. This value is owned by the caller, and must survive for the lifetime of the table.
 * @param lock The lock to acquire when modifying shared mutable state.
 * @param root_table The table from which the entry should be allocated.
 */
static pl_trampoline *pl_trampoline_alloc (pl_trampoline_table_config *config, pthread_mutex_t *lock, pl_trampoline_table **table_head) {
    pthread_mutex_lock(lock);
    
    /* Check for an active trampoline table with available entries. */
    pl_trampoline_table *table = *table_head;
    if (table == NULL || table->free_list == NULL) {
        table = pl_trampoline_table_alloc (config);
        if (table == NULL) {
            return NULL;
        }
        
        /* Insert the new table at the top of the list */
        table->next = *table_head;
        if (table->next != NULL)
            table->next->prev = table;
        
        *table_head = table;
    }
    
    /* Claim the free entry */
    pl_trampoline *entry = (*table_head)->free_list;
    (*table_head)->free_list = entry->next;
    (*table_head)->free_count--;
    entry->next = NULL;
    
    pthread_mutex_unlock(lock);
    
    return entry;
}

/**
 * Given a trampoline's code pointer, return its associated data pointer.
 */
static void *pl_trampoline_data_ptr (void *code_ptr) {
    return (uint8_t *) code_ptr - PAGE_SIZE;
}

/**
 * Deallocate a trampoline and return it to the free list.
 *
 * @param lock The lock to acquire when modifying shared mutable state.
 * @param root_table The root table from which the entry should be deallocated.
 * @param tramp The trampoline to deallocate.
 */
static void pl_trampoline_free (pthread_mutex_t *lock, pl_trampoline_table **table_head, pl_trampoline *tramp) {    
    pthread_mutex_lock(lock);
    
    /* Fetch the table references */
    pl_trampoline_table *table = tramp->table;
    
    /* Return the entry to the free list */
    tramp->next = table->free_list;
    table->free_list = tramp;
    table->free_count++;
    
    /* If all trampolines within this table are free, and at least one other table exists, deallocate
     * the table */
    if (table->free_count == table->config->trampoline_count && *table_head != table) {
        /* Remove from the list */
        if (table->prev != NULL)
            table->prev->next = table->next;
        
        if (table->next != NULL)
            table->next->prev = table->prev;
        
        /* Deallocate pages */
        kern_return_t kt;
        kt = vm_deallocate (mach_task_self(), table->data_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS)
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
        
        kt = vm_deallocate (mach_task_self(), table->trampoline_page, PAGE_SIZE);
        if (kt != KERN_SUCCESS)
            fprintf(stderr, "vm_deallocate() failure: %d at %s:%d\n", kt, __FILE__, __LINE__);
        
        /* Deallocate free list */
        free (table->free_list_pool);
        free (table);
    } else if (*table_head != table) {
        /* Otherwise, bump this table to the top of the list */
        table->prev = NULL;
        table->next = *table_head;
        if (*table_head != NULL)
            (*table_head)->prev = table;
        
        *table_head = table;
    }
    
    pthread_mutex_unlock (lock);
}

#pragma mark - Function implementations

/* Global lock for our mutable state. Must be held when accessing the trampoline tables. */
static pthread_mutex_t blockimp_lock = PTHREAD_MUTEX_INITIALIZER;

/* Trampoline tables for objc_msgSend_stret() dispatch. */
static pl_trampoline_table *blockimp_table_stret = NULL;

/* Trampoline tables for objc_msgSend() dispatch. */
static pl_trampoline_table *blockimp_table = NULL;

/**
 * 
 */
IMP a2_imp_implementationWithBlock (id block) {
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
	if (a2_blockHasStret(block)) {
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

id a2_imp_getBlock(IMP anImp) {
    /* Prefer Apple's implementation */
    if (&imp_getBlock != NULL) {
        return (id)imp_getBlock(anImp);
    }
	
    /* Fetch the config data and return the block reference. */
    void **config = pl_trampoline_data_ptr(anImp);
    return config[0];
}

BOOL a2_imp_removeBlock(IMP anImp) {
    /* Prefer Apple's implementation */
    if (&imp_removeBlock != NULL)
        return imp_removeBlock(anImp);
	
	if (!anImp)
		return NO;
    
    /* Fetch the config data */
    void **config = pl_trampoline_data_ptr(anImp);
	id block = config[0];
    pl_trampoline *tramp = config[1];
	
	/* Drop the trampoline allocation */
	if (a2_blockHasStret(block)) {
		pl_trampoline_free(&blockimp_lock, &blockimp_table_stret, tramp);
	} else {
		pl_trampoline_free(&blockimp_lock, &blockimp_table, tramp);
	}
	
    /* Release the block */
    Block_release(block);
	
    return YES;
}