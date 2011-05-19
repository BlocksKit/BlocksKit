//
//  BlocksKit_Globals.h
//  BlocksKit
//

#pragma once

#if TARGET_IPHONE_SIMULATOR
    #define BK_HAS_UIKIT 1
    #define BK_HAS_APPKIT 0
#elif TARGET_OS_IPHONE
    #define BK_HAS_UIKIT 1
    #define BK_HAS_APPKIT 0
#else
    #if CHAMELEON
        #define BK_HAS_UIKIT 1
    #else
        #define BK_HAS_UIKIT 0
    #endif
#define BK_HAS_APPKIT 1
#endif


typedef void(^BKBlock)();

typedef void(^BKSenderBlock)(id sender);
typedef id(^BKTransformBlock)(id obj);
typedef BOOL(^BKValidationBlock)(id obj);

typedef void(^BKIndexBlock)(NSUInteger index);
typedef BOOL(^BKIndexValidationBlock)(NSUInteger index);

typedef void(^BKWithObjectBlock)(id obj, id arg);
typedef void(^BKObservationBlock)(id obj, NSDictionary *change);
typedef void(^BKKeyValueBlock)(id key, id obj);
typedef id(^BKKeyValueTransformBlock)(id key, id obj);
typedef id(^BKAccumulationBlock)(id sum, id obj);