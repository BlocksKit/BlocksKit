/*
 * blockimp_trampoline_table.c
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


#include "blockimp_trampoline_table.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

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
pl_trampoline *pl_trampoline_alloc (pl_trampoline_table_config *config, pthread_mutex_t *lock, pl_trampoline_table **table_head) {
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
void *pl_trampoline_data_ptr (void *code_ptr) {
    return (uint8_t *) code_ptr - PAGE_SIZE;
}

/**
 * Deallocate a trampoline and return it to the free list.
 *
 * @param lock The lock to acquire when modifying shared mutable state.
 * @param root_table The root table from which the entry should be deallocated.
 * @param tramp The trampoline to deallocate.
 */
void pl_trampoline_free (pthread_mutex_t *lock, pl_trampoline_table **table_head, pl_trampoline *tramp) {    
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
