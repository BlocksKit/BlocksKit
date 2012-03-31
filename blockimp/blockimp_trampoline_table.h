/*
 * blockimp_trampoline_table.h
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

#pragma once

#ifndef PL_BLOCKIMP_TRAMPOLINE_PRIVATE
#define PL_BLOCKIMP_TRAMPOLINE_PRIVATE

#include <mach/mach.h>
#include <pthread.h>

typedef struct pl_trampoline_table pl_trampoline_table;
typedef struct pl_trampoline pl_trampoline;

/*
 * Trampoline table configuration
 */
typedef struct pl_trampoline_table_config {
    /* The trampoline size */
    uint32_t trampoline_size;
    
    /* The page offset at which the trampolines are located. */
    uint32_t page_offset;

    /* The number of trampolines allocated per page. */
    uint32_t trampoline_count;

    /** The template code page. */
    void *template_page;
} pl_trampoline_table_config;

/*
 * A double-linked list of trampoline table entries.
 */
struct pl_trampoline_table {
    /* Table configuration */
    pl_trampoline_table_config *config;

    /* Contigious writable and executable pages */
    vm_address_t data_page;
    vm_address_t trampoline_page;
    
    /* free list tracking */
    uint16_t free_count;
    pl_trampoline *free_list;
    pl_trampoline *free_list_pool;
    
    pl_trampoline_table *prev;
    pl_trampoline_table *next;
};

/*
 * A linked list of trampoline table entries.
 */
struct pl_trampoline {
    /* The actual trampoline. */
    void *(*trampoline)();

    /** The table in which the entry is allocated. */
    pl_trampoline_table *table;

    /* Next entry in the trampoline list. */
    pl_trampoline *next;
};

pl_trampoline *pl_trampoline_alloc (pl_trampoline_table_config *config, pthread_mutex_t *lock, pl_trampoline_table **table_head);
void pl_trampoline_free (pthread_mutex_t *lock, pl_trampoline_table **table_head, pl_trampoline *tramp);
void *pl_trampoline_data_ptr (void *code_ptr);

#endif /* PL_BLOCKIMP_TRAMPOLINE_PRIVATE */