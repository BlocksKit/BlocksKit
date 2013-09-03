//
//  BKMacros.h
//  BlocksKit
//
//  Includes code by Michael Ash. <https://github.com/mikeash>.
//

#import "NSArray+BlocksKit.h"
#import "NSSet+BlocksKit.h"
#import "NSDictionary+BlocksKit.h"
#import "NSIndexSet+BlocksKit.h"

#ifndef __BLOCKSKIT_MACROS__
#define __BLOCKSKIT_MACROS__

#define __BK_EACH_WRAPPER(...) (^{ __block CFMutableDictionaryRef BK_eachTable = nil; \
		(void)BK_eachTable; \
		__typeof__(__VA_ARGS__) BK_retval = __VA_ARGS__; \
		if(BK_eachTable) \
			CFRelease(BK_eachTable); \
		return BK_retval; \
	}())

#define __BK_EACH_WRAPPER_VOID(...) (^{ __block CFMutableDictionaryRef BK_eachTable = nil; \
		(void)BK_eachTable; \
		__VA_ARGS__; \
		if(BK_eachTable) \
			CFRelease(BK_eachTable); \
	}())

#define BK_EACH(collection, ...) __BK_EACH_WRAPPER_VOID([collection each:^(id obj) { __VA_ARGS__ }])
#define BK_MAP(collection, ...) __BK_EACH_WRAPPER([collection map: ^id (id obj) { return (__VA_ARGS__); }])
#define BK_SELECT(collection, ...) __BK_EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BK_REJECT(collection, ...) __BK_EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) == 0; }])
#define BK_MATCH(collection, ...) __BK_EACH_WRAPPER([collection match: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BK_REDUCE(collection, initial, ...) __BK_EACH_WRAPPER([collection reduce: (initial) withBlock: ^id (id a, id b) { return (__VA_ARGS__); }])

// BK_APPLY is not wrapped, because we don't guarantee that the order matches the current collection during parallel execution.
#define BK_APPLY(collection, ...) [collection apply:^(id obj) { __VA_ARGS__ }]

static inline id BKNextHelper(NSArray *array, CFMutableDictionaryRef *eachTablePtr) {

    if (!*eachTablePtr) {
        CFDictionaryKeyCallBacks keycb = {
            0,
            kCFTypeDictionaryKeyCallBacks.retain,
            kCFTypeDictionaryKeyCallBacks.release,
            kCFTypeDictionaryKeyCallBacks.copyDescription,
            NULL,
            NULL
        };
        *eachTablePtr = CFDictionaryCreateMutable(NULL, 0, &keycb, &kCFTypeDictionaryValueCallBacks);
    }

    NSEnumerator *enumerator = (__bridge id)CFDictionaryGetValue(*eachTablePtr, (__bridge CFArrayRef)array);
    if (!enumerator) {
        enumerator = [array objectEnumerator];
        CFDictionarySetValue(*eachTablePtr, (__bridge CFArrayRef)array, (__bridge void *)enumerator);
    }
    return [enumerator nextObject];
}

#define BK_NEXT(array) BKNextHelper(array, &BK_eachTable)

#ifndef EACH
#define EACH BK_EACH
#endif

#ifndef APPLY
#define APPLY BK_APPLY
#endif

#ifndef MAP
#define MAP BK_MAP
#endif

#ifndef SELECT
#define SELECT BK_SELECT
#endif

#ifndef REJECT
#define REJECT BK_REJECT
#endif

#ifndef MATCH
#define MATCH BK_MATCH
#endif

#ifndef REDUCE
#define REDUCE BK_REDUCE
#endif

#ifndef NEXT
#define NEXT BK_NEXT
#endif

#endif
