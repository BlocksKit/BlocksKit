/*
 * blockimp_config.c
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

#include "blockimp_private.h"
#include "blockimp_trampoline_table.h"

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