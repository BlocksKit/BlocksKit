//
//  BKGlobals.h
//  %PROJECT
//

#pragma once

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

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
#import <MessageUI/MessageUI.h>

typedef void(^BKViewBlock)(UIView *view);
typedef void(^BKGestureRecognizerBlock)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location);
typedef void(^BKTouchBlock)(NSSet* set, UIEvent* event);
#endif

#if BK_HAS_APPKIT
#import <Cocoa/Cocoa.h>

typedef void(^BKViewBlock)(NSView *view);
typedef void(^BKEventBlock)(NSEvent* event);
#endif

typedef void(^BKBlock)(void); // compatible with dispatch_block_t
typedef void(^BKSenderBlock)(id sender);
typedef void(^BKDataBlock)(NSData *data);
typedef void(^BKErrorBlock)(NSError *error);
typedef void(^BKIndexBlock)(NSUInteger index);
typedef void(^BKTimerBlock)(NSTimeInterval time);
typedef void(^BKResponseBlock)(NSURLResponse *response);

typedef void(^BKWithObjectBlock)(id obj, id arg);
typedef void(^BKObservationBlock)(id obj, NSDictionary *change);
typedef void(^BKKeyValueBlock)(id key, id obj);

typedef BOOL(^BKValidationBlock)(id obj);
typedef BOOL(^BKKeyValueValidationBlock)(id key, id obj);
typedef BOOL(^BKIndexValidationBlock)(NSUInteger index);

typedef id(^BKReturnBlock)(void);
typedef id(^BKTransformBlock)(id obj);
typedef id(^BKKeyValueTransformBlock)(id key, id obj);
typedef id(^BKAccumulationBlock)(id sum, id obj);

typedef NSUInteger(^BKIndexTransformBlock)(NSUInteger index);

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#define BK_AUTORELEASE(o) o
#define BK_SHOULD_DEALLOC 0
#define BK_RELEASE(o)
#define BK_SET_RETAINED(var, val) var = val
#else
#define BK_AUTORELEASE(o) [o autorelease]
#define BK_SHOULD_DEALLOC 1
#define BK_RELEASE(o) [o release]
#define BK_SET_RETAINED(var, val) { \
if (var) \
[var release]; \
var = [val retain]; \
}
#endif