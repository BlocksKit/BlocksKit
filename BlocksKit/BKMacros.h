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

#ifndef __BKMacros_h__
#define __BKMacros_h__

#define EACH_WRAPPER(...) (^{ __block CFMutableDictionaryRef MA_eachTable = nil; \
        (void)MA_eachTable; \
        __typeof__(__VA_ARGS__) MA_retval = __VA_ARGS__; \
        if(MA_eachTable) \
            CFRelease(MA_eachTable); \
        return MA_retval; \
    }())

#define EACH(collection, ...) EACH_WRAPPER([collection each:^(id obj) { __VA_ARGS__ }];
#define MAP(collection, ...) EACH_WRAPPER([collection map: ^id (id obj) { return (__VA_ARGS__); }])
#define SELECT(collection, ...) EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define REJECT(collection, ...) EACH_WRAPPER([collection select: ^BOOL (id obj) { return (__VA_ARGS__) == 0; }])
#define MATCH(collection, ...) EACH_WRAPPER([collection match: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define REDUCE(collection, initial, ...) EACH_WRAPPER([collection reduce: (initial) block: ^id (id a, id b) { return (__VA_ARGS__); }])

#endif