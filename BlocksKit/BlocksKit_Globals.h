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

#if BK_HAS_UIKIT
#import <UIKit/UIKit.h>
#endif


typedef void(^BKBlock)(void); // compatible with dispatch_block_t

typedef void(^BKSenderBlock)(id sender);
typedef id(^BKTransformBlock)(id obj);
typedef BOOL(^BKValidationBlock)(id obj);

typedef void(^BKIndexBlock)(NSUInteger index);
typedef BOOL(^BKIndexValidationBlock)(NSUInteger index);

typedef BOOL(^BKWebViewStartBlock)(NSURLRequest *request, UIWebViewNavigationType navigationType);
typedef void(^BKErrorBlock)(NSError *error);

typedef void(^BKWithObjectBlock)(id obj, id arg);
typedef void(^BKObservationBlock)(id obj, NSDictionary *change);
typedef void(^BKKeyValueBlock)(id key, id obj);
typedef id(^BKKeyValueTransformBlock)(id key, id obj);
typedef id(^BKAccumulationBlock)(id sum, id obj);

typedef void(^BKTouchBlock)(NSSet* set, UIEvent* event);