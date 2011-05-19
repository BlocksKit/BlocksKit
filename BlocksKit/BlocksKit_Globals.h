//
//  BlocksKit_Globals.h
//  BlocksKit
//

#pragma once

#if TARGET_IPHONE_SIMULATOR
#define BK_IS_IOS 1
#define BK_IS_MAC 0
#elif TARGET_OS_IPHONE
#define BK_IS_IOS 1
#define BK_IS_MAC 0
#else
#define BK_IS_IOS 0
#define BK_IS_MAC 1
#endif


typedef void(^BKBlock)();
typedef void(^BKSenderBlock)(id sender);
typedef void(^BKWithObjectBlock)(id obj, id arg);

typedef void(^BKObservationBlock)(id obj, NSDictionary *change);
typedef void(^BKKeyValueBlock)(id key, id obj);

typedef BOOL(^BKValidationBlock)(id obj);

typedef id(^BKTransformBlock)(id obj);
typedef id(^BKKeyValueTransformBlock)(id key, id obj);

typedef id(^BKAccumulationBlock)(id sum, id obj);