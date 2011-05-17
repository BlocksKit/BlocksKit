//
//  NSObject+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 5/17/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import "NSObject+BlocksKit.h"
#import <dispatch/dispatch.h>

static inline dispatch_time_t dTimeDelay(NSTimeInterval time) {
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

@implementation NSObject (BlocksKit)

- (id)performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id obj) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(obj);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, self); });
    
    return [wrappingBlock autorelease];
}

- (id)performBlock:(void (^)(id obj, id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id, id) = ^(BOOL cancel, id obj, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(obj, arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{ wrappingBlock(NO, self, anObject); });
    
    return [wrappingBlock autorelease];
}

+ (id)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled)block();
    };
    
    wrappingBlock = [[wrappingBlock copy] autorelease];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{ wrappingBlock(NO); });
    
    return wrappingBlock;    
}

+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject); });
    
    return [wrappingBlock autorelease];    
}

+ (void)cancelBlock:(id)block {
    if (!block) return;
    void (^aWrappingBlock)(BOOL) = (void(^)(BOOL))block;
    aWrappingBlock(YES);
}

@end
