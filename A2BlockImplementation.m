//
//  A2BlockImplementation.c
//  BlocksKitTest2
//
//  Created by Zachary Waldowski on 4/1/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <mach/mach.h>

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

#define TRAMP(tramp)                                \
static inline uintptr_t tramp(void) {           \
extern void *_##tramp;                      \
return ((uintptr_t)&_##tramp) & ~1UL;       \
}
// Scalar return
TRAMP(a1a2_tramphead);   // trampoline header code
TRAMP(a1a2_firsttramp);  // first trampoline
TRAMP(a1a2_nexttramp);   // second trampoline
TRAMP(a1a2_trampend);    // after the last trampoline
TRAMP(a1a2_tramphead_argonly);   // trampoline header code, arguments only
TRAMP(a1a2_firsttramp_argonly);  // first trampoline, arguments only
TRAMP(a1a2_nexttramp_argonly);   // second trampoline, arguments only
TRAMP(a1a2_trampend_argonly);    // after the last trampoline, arguments only

// Struct return
TRAMP(a2a3_tramphead);
TRAMP(a2a3_firsttramp);
TRAMP(a2a3_nexttramp);
TRAMP(a2a3_trampend);
TRAMP(a2a3_tramphead_argonly);
TRAMP(a2a3_firsttramp_argonly);
TRAMP(a2a3_nexttramp_argonly);
TRAMP(a2a3_trampend_argonly);

#define HAS_FLAG(a, b) ((a & b) == b)

// slot size is 8 bytes on both i386 and x86_64 (because of bytes-per-call instruction is > 4 for both)
#define SLOT_SIZE 8

// unsigned value, any value, larger thna # of blocks that fit in the page pair
#define LAST_SLOT_MARKER 4241

#define TRAMPOLINE_PAGE_PAIR_HEADER_SIZE (sizeof(uint32_t) + sizeof(struct _TrampolineBlockPagePair *) + sizeof(struct _TrampolineBlockPagePair *))

typedef struct _TrampolineBlockPagePair {
	struct _TrampolineBlockPagePair *nextPagePair;
	struct _TrampolineBlockPagePair *nextAvailablePage;
	uint32_t nextAvailable;
	uint8_t blocks[ PAGE_SIZE - TRAMPOLINE_PAGE_PAIR_HEADER_SIZE ] __attribute__((unavailable));
	uint8_t trampolines[PAGE_SIZE];

} TrampolineBlockPagePair;

static TrampolineBlockPagePair *headPagePairs[4];

static pthread_rwlock_t _blockLock;

void a2_block_lock_init(void) __attribute__((constructor));
void a2_block_lock_destroy(void) __attribute__((destructor));

void a2_block_lock_init(void) {
	pthread_rwlock_init(&_blockLock, NULL);
}

void a2_block_lock_destroy(void) {
	pthread_rwlock_destroy(&_blockLock);
}

static inline uint32_t _headerSize() {
    uint32_t headerSize = (uint32_t) (a1a2_firsttramp() - a1a2_tramphead());
	
    // make sure stret and non-stret sizes match
    assert(a2a3_firsttramp() - a2a3_tramphead() == headerSize);
	
    return headerSize;
}

static inline uint32_t _slotSize() {
    uint32_t slotSize = (uint32_t) (a1a2_nexttramp() - a1a2_firsttramp());
	
    // make sure stret and non-stret sizes match
    assert(a2a3_nexttramp() - a2a3_firsttramp() == slotSize);
	
    return slotSize;
}

static inline bool trampolinesAreThumb(void) {
    extern void *_a1a2_firsttramp;
    extern void *_a1a2_nexttramp;
    extern void *_a2a3_firsttramp;
    extern void *_a2a3_nexttramp;
    extern void *_a1a2_firsttramp_argonly;
    extern void *_a1a2_nexttramp_argonly;
    extern void *_a2a3_firsttramp_argonly;
    extern void *_a2a3_nexttramp_argonly;
	
    // make sure thumb-edness of all trampolines match
    assert(((uintptr_t)&_a1a2_firsttramp) % 2 == 
           ((uintptr_t)&_a2a3_firsttramp) % 2);
    assert(((uintptr_t)&_a1a2_firsttramp) % 2 == 
           ((uintptr_t)&_a1a2_nexttramp) % 2);
    assert(((uintptr_t)&_a1a2_firsttramp) % 2 == 
           ((uintptr_t)&_a2a3_nexttramp) % 2);
    assert(((uintptr_t)&_a1a2_firsttramp_argonly) % 2 == 
           ((uintptr_t)&_a2a3_firsttramp_argonly) % 2);
    assert(((uintptr_t)&_a1a2_firsttramp_argonly) % 2 == 
           ((uintptr_t)&_a1a2_nexttramp_argonly) % 2);
    assert(((uintptr_t)&_a1a2_firsttramp_argonly) % 2 == 
           ((uintptr_t)&_a2a3_nexttramp_argonly) % 2);
	
    return ((uintptr_t)&_a1a2_firsttramp) % 2;
}

static inline uint32_t _slotsPerPagePair() {
    uint32_t slotSize = _slotSize();
    uint32_t slotsPerPagePair = PAGE_SIZE / slotSize;
    return slotsPerPagePair;
}

static inline uint32_t _paddingSlotCount() {
    uint32_t headerSize = _headerSize();
    uint32_t slotSize = _slotSize();
    uint32_t paddingSlots = headerSize / slotSize;
    return paddingSlots;
}

static inline void **_payloadAddressAtIndex(TrampolineBlockPagePair *pagePair, uint32_t index) {
    uint32_t slotSize = _slotSize();
    uintptr_t baseAddress = (uintptr_t) pagePair; 
    uintptr_t payloadAddress = baseAddress + (slotSize * index);
    return (void **)payloadAddress;
}

static inline IMP _trampolineAddressAtIndex(TrampolineBlockPagePair *pagePair, uint32_t index) {
    uint32_t slotSize = _slotSize();
    uintptr_t baseAddress = (uintptr_t) &(pagePair->trampolines);
    uintptr_t trampolineAddress = baseAddress + (slotSize * index);
	
#if defined(__arm__)
    if (trampolinesAreThumb()) trampolineAddress++;
#endif
	
    return (IMP)trampolineAddress;
}

static inline void _lock() {
	pthread_rwlock_wrlock(&_blockLock);
}

static inline void _unlock() {
	pthread_rwlock_unlock(&_blockLock);
}

static inline int _headPagePairIdx(BOOL returnArgumentOnStack, BOOL argumentsOnly) {
	if (returnArgumentOnStack && argumentsOnly) {
		return 2;
	} else if (returnArgumentOnStack) {
		return 1;
	} else if (argumentsOnly) {
		return 3;
	} else {
		return 0;
	}
}

static inline TrampolineBlockPagePair *_headPagePair(BOOL returnArgumentOnStack, BOOL argumentsOnly) {
	return headPagePairs[_headPagePairIdx(returnArgumentOnStack, argumentsOnly)];
}

static inline struct Block_descriptor_3 * _Block_descriptor_3(BlockRef aBlock)
{
    if (!(aBlock->flags & BLOCK_HAS_SIGNATURE)) return NULL;
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct Block_descriptor_1);
    if (aBlock->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct Block_descriptor_2);
    }
    return (struct Block_descriptor_3 *)desc;
}

static inline const char * _Block_signature(void *aBlock)
{
    struct Block_descriptor_3 *desc3 = _Block_descriptor_3(aBlock);
    if (!desc3) return NULL;
	
    return desc3->signature;
}

// Checks for a valid signature, not merely the BLOCK_HAS_SIGNATURE bit.
static inline BOOL _Block_has_signature(void *aBlock) {
    return _Block_signature(aBlock) ? YES : NO;
}

static inline BOOL _Block_use_stret(void *aBlock) {
    BlockRef layout = (BlockRef)aBlock;
	
    int requiredFlags = BLOCK_HAS_SIGNATURE | BLOCK_USE_STRET;
    return (layout->flags & requiredFlags) == requiredFlags;
}

static TrampolineBlockPagePair *_allocateTrampolinesAndData(BOOL returnArgumentOnStack, BOOL argumentsOnly) {    
    vm_address_t dataAddress;
    
    // make sure certain assumptions are met
    assert(PAGE_SIZE == 4096);
    assert(sizeof(TrampolineBlockPagePair) == 2*PAGE_SIZE);
    assert(_slotSize() == 8);
    assert(_headerSize() >= TRAMPOLINE_PAGE_PAIR_HEADER_SIZE);
    assert((_headerSize() % _slotSize()) == 0);
	
	if (argumentsOnly) {
		NSLog(@"%lu %lu", a1a2_tramphead_argonly() + PAGE_SIZE, a1a2_trampend_argonly());
		NSLog(@"%lu %lu", a2a3_tramphead_argonly() + PAGE_SIZE, a2a3_trampend_argonly());
		
		assert(a1a2_tramphead_argonly() % PAGE_SIZE == 0);
		assert(a1a2_tramphead_argonly() + PAGE_SIZE == a1a2_trampend_argonly());
		assert(a2a3_tramphead_argonly() % PAGE_SIZE == 0);
		assert(a2a3_tramphead_argonly() + PAGE_SIZE == a2a3_trampend_argonly());
	} else {
		assert(a1a2_tramphead() % PAGE_SIZE == 0);
		assert(a1a2_tramphead() + PAGE_SIZE == a1a2_trampend());
		assert(a2a3_tramphead() % PAGE_SIZE == 0);
		assert(a2a3_tramphead() + PAGE_SIZE == a2a3_trampend());
	}
	
    TrampolineBlockPagePair *headPagePair = _headPagePair(returnArgumentOnStack, argumentsOnly);
    
    if (headPagePair) {
        assert(headPagePair->nextAvailablePage == NULL);
    }
    
    int i;
    kern_return_t result = KERN_FAILURE;
    for(i = 0; i < 5; i++) {
		result = vm_allocate(mach_task_self(), &dataAddress, PAGE_SIZE * 2, TRUE);
        if (result != KERN_SUCCESS) {
            mach_error("vm_allocate failed", result);
            return NULL;
        }
		
        vm_address_t codeAddress = dataAddress + PAGE_SIZE;
        result = vm_deallocate(mach_task_self(), codeAddress, PAGE_SIZE);
        if (result != KERN_SUCCESS) {
            mach_error("vm_deallocate failed", result);
            return NULL;
        }
		
		
        
		uintptr_t codePage;
		if (argumentsOnly)
			codePage = returnArgumentOnStack ? (a2a3_firsttramp_argonly() & ~(PAGE_MASK)) : (a1a2_firsttramp_argonly() & ~(PAGE_MASK));
		else
			codePage = returnArgumentOnStack ? (a2a3_firsttramp() & ~(PAGE_MASK)) : (a1a2_firsttramp() & ~(PAGE_MASK));
        vm_prot_t currentProtection, maxProtection;
        result = vm_remap(mach_task_self(), &codeAddress, PAGE_SIZE, 0, FALSE, mach_task_self(),
                          codePage, TRUE, &currentProtection, &maxProtection, VM_INHERIT_SHARE);
        if (result != KERN_SUCCESS) {
            result = vm_deallocate(mach_task_self(), dataAddress, PAGE_SIZE);
            if (result != KERN_SUCCESS) {
                mach_error("vm_deallocate for retry failed.", result);
                return NULL;
            } 
        } else
            break;
    }
    
    if (result != KERN_SUCCESS)
        return NULL; 
    
    TrampolineBlockPagePair *pagePair = (TrampolineBlockPagePair *) dataAddress;
    pagePair->nextAvailable = _paddingSlotCount();
    pagePair->nextPagePair = NULL;
    pagePair->nextAvailablePage = NULL;
    void **lastPageBlockPtr = _payloadAddressAtIndex(pagePair, _slotsPerPagePair() - 1);
    *lastPageBlockPtr = (void*)(uintptr_t) LAST_SLOT_MARKER;
    
    if (headPagePair) {
        TrampolineBlockPagePair *lastPage = headPagePair;
        while(lastPage->nextPagePair)
            lastPage = lastPage->nextPagePair;
        
        lastPage->nextPagePair = pagePair;
        headPagePairs[_headPagePairIdx(returnArgumentOnStack, argumentsOnly)]->nextAvailablePage = pagePair;
    } else {
        headPagePairs[_headPagePairIdx(returnArgumentOnStack, argumentsOnly)] = pagePair;
    }
    
    return pagePair;
}

static TrampolineBlockPagePair *_getOrAllocatePagePairWithNextAvailable(BOOL returnArgumentOnStack, BOOL argumentsOnly) {
    TrampolineBlockPagePair *headPagePair = _headPagePair(returnArgumentOnStack, argumentsOnly);
	
    if (!headPagePair)
        return _allocateTrampolinesAndData(returnArgumentOnStack, argumentsOnly);
    
    if (headPagePair->nextAvailable) // make sure head page is filled first
        return headPagePair;
    
    if (headPagePair->nextAvailablePage) // check if there is a page w/a hole
        return headPagePair->nextAvailablePage;
    
    return _allocateTrampolinesAndData(returnArgumentOnStack, argumentsOnly); // tack on a new one
}

static TrampolineBlockPagePair *_pagePairAndIndexContainingIMP(IMP anImp, uint32_t *outIndex, TrampolineBlockPagePair **outHeadPagePair) {
    uintptr_t impValue = (uintptr_t) anImp;
    uint32_t i;
	
    for(i = 0; i < 4; i++) {
        TrampolineBlockPagePair *pagePair = headPagePairs[i];
        
        while(pagePair) {
            uintptr_t startOfTrampolines = (uintptr_t) &(pagePair->trampolines);
            uintptr_t endOfTrampolines = ((uintptr_t) startOfTrampolines) + PAGE_SIZE;
            
            if ( (impValue >=startOfTrampolines) && (impValue <= endOfTrampolines) ) {
                if (outIndex) {
                    *outIndex = (uint32_t) ((impValue - startOfTrampolines) / SLOT_SIZE);
                }
                if (outHeadPagePair) {
                    *outHeadPagePair = headPagePairs[i];
                }
                return pagePair;
            }
            
            pagePair = pagePair->nextPagePair;
        }
    }
    
    return NULL;
}

static IMP _a2_imp_implementationWithBlock(id block, BOOL argumentsOnly) {
	if (!block) return NULL;
	
	block = Block_copy(block);
	
	_lock();
	
    BOOL returnArgumentOnStack = _Block_use_stret(block);
	
	TrampolineBlockPagePair *pagePair = _getOrAllocatePagePairWithNextAvailable(returnArgumentOnStack, argumentsOnly);
    if (!headPagePairs[!!returnArgumentOnStack])
        headPagePairs[!!returnArgumentOnStack] = pagePair;
	
    uint32_t index = pagePair->nextAvailable;
    void **payloadAddress = _payloadAddressAtIndex(pagePair, index);
    assert((index < 1024) || (index == LAST_SLOT_MARKER));
    
    uint32_t nextAvailableIndex = (uint32_t) *((uintptr_t *) payloadAddress);
    if (nextAvailableIndex == 0)
        // first time through, slots are filled with zeros, fill sequentially
        pagePair->nextAvailable = index + 1;
    else if (nextAvailableIndex == LAST_SLOT_MARKER) {
        // last slot is filled with this as marker
        // page now full, remove from available page linked list
        pagePair->nextAvailable = 0;
        TrampolineBlockPagePair *iteratorPair = headPagePairs[!!returnArgumentOnStack];
        while(iteratorPair && (iteratorPair->nextAvailablePage != pagePair))
            iteratorPair = iteratorPair->nextAvailablePage;
        if (iteratorPair) {
            iteratorPair->nextAvailablePage = pagePair->nextAvailablePage;
            pagePair->nextAvailablePage = NULL;
        }
    } else {
        // empty slot at index contains pointer to next available index
        pagePair->nextAvailable = nextAvailableIndex;
    }
    
    *payloadAddress = block;
    IMP trampoline = _trampolineAddressAtIndex(pagePair, index);
    
    return trampoline;

	_unlock();
}

extern IMP a2_imp_implementationWithBlock(id block) {
	return _a2_imp_implementationWithBlock(block, NO);
}

extern IMP a2_imp_implementationWithArgumentsOnlyBlock(id block) {
	return _a2_imp_implementationWithBlock(block, YES);
}

extern void *a2_imp_getBlock(IMP anImp) {
	if (!anImp) return NULL;
	_lock();
	
	uint32_t index;
    TrampolineBlockPagePair *pagePair = _pagePairAndIndexContainingIMP(anImp, &index, NULL);
    
    if (!pagePair) {
        _unlock();
        return NULL;
    }
    
    void *potentialBlock = *_payloadAddressAtIndex(pagePair, index);
    
    if ((uintptr_t) potentialBlock == (uintptr_t) LAST_SLOT_MARKER) {
        _unlock();
        return NULL;
    }
    
    if ((uintptr_t) potentialBlock < (uintptr_t) _slotsPerPagePair()) {
        _unlock();
        return NULL;
    }
    
    _unlock();
	
	return potentialBlock;
}

extern BOOL a2_imp_removeBlock(IMP anImp) {
	TrampolineBlockPagePair *pagePair;
    TrampolineBlockPagePair *headPagePair;
    uint32_t index;
    
    if (!anImp) return NO;
    
    _lock();
    pagePair = _pagePairAndIndexContainingIMP(anImp, &index, &headPagePair);
    
    if (!pagePair) {
        _unlock();
        return NO;
    }
    
    void **payloadAddress = _payloadAddressAtIndex(pagePair, index);
    void *block = *payloadAddress;
    // block is released below
    
    if (pagePair->nextAvailable) {
        *payloadAddress = (void *) (uintptr_t) pagePair->nextAvailable;
        pagePair->nextAvailable = index;
    } else {
        *payloadAddress = (void *) (uintptr_t) LAST_SLOT_MARKER; // nada after this one is used
        pagePair->nextAvailable = index;
    }
    
    // make sure this page is on available linked list
    TrampolineBlockPagePair *pagePairIterator = headPagePair;
    
    // see if pagePair is the next available page for any existing pages
    while(pagePairIterator->nextAvailablePage && (pagePairIterator->nextAvailablePage != pagePair))
        pagePairIterator = pagePairIterator->nextAvailablePage;
    
    if (! pagePairIterator->nextAvailablePage) { // if iteration stopped because nextAvail was NULL
        // add to end of list.
        pagePairIterator->nextAvailablePage = pagePair;
        pagePair->nextAvailablePage = NULL;
    }
    
    _unlock();
    Block_release(block);
    return YES;
}