//
//  NSObject+BlocksKit.m
//  BlocksKit
//

#import "NSObject+BlocksKit.h"
#import <objc/runtime.h>

typedef void(^BKInternalWrappingBlock)(BOOL cancel);

static inline dispatch_time_t dTimeDelay(NSTimeInterval time) {
    int64_t delta = (NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

@implementation NSObject (BlocksKit)

- (id)performBlock:(BKSenderBlock)block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    BKInternalWrappingBlock wrapper = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(self);
    };
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrapper(NO); });
    
    return BK_AUTORELEASE([wrapper copy]);
}

+ (id)performBlock:(BKBlock)block afterDelay:(NSTimeInterval)delay {
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    BKInternalWrappingBlock wrapper = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block();
    };
    
	dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{ wrapper(NO); });
    
    return BK_AUTORELEASE([wrapper copy]);
}

+ (void)cancelBlock:(id)block {
    if (!block) return;
    BKInternalWrappingBlock wrapper = block;
    wrapper(YES);
}

+ (void)swizzleSelector:(SEL)oldSel withSelector:(SEL)newSel {
    Method oldMethod = class_getInstanceMethod(self, oldSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    method_exchangeImplementations(oldMethod, newMethod);
}

@end