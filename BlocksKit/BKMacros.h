//
//  BKMacros.h
//  %PROJECT
//
//  Includes code by Michael Ash. <https://github.com/mikeash>. 2010. BSD.
//

#import "NSArray+BlocksKit.h"
#import "NSSet+BlocksKit.h"
#import "NSDictionary+BlocksKit.h"
#import "NSIndexSet+BlocksKit.h"

#ifndef __BLOCKSKIT_MACROS__
#define __BLOCKSKIT_MACROS__

#define __BK_EACH_WRAPPER(...) (^{ __block CFMutableDictionaryRef MA_eachTable = nil; \
		(void)MA_eachTable; \
		__typeof__(__VA_ARGS__) MA_retval = __VA_ARGS__; \
		if(MA_eachTable) \
			CFRelease(MA_eachTable); \
		return MA_retval; \
	}())

#define BK_EACH(collection, ...) __BK_EACH_WRAPPER([collection each:^(id obj) { __VA_ARGS__ }];
#define BK_APPLY(collection, ...) __BK_EACH_WRAPPER([collection apply:^(id obj) { __VA_ARGS__ }];
#define BK_MAP(collection, ...) __BK_EACH_WRAPPER([collection map: ^id (id obj) { return (__VA_ARGS__); }])
#define BK_SELECT(collection, ...) __BK_EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BK_REJECT(collection, ...) __BK_EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) == 0; }])
#define BK_MATCH(collection, ...) __BK_EACH_WRAPPER([collection match: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BK_REDUCE(collection, initial, ...) __BK_EACH_WRAPPER([collection reduce: (initial) block: ^id (id a, id b) { return (__VA_ARGS__); }])

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

#endif