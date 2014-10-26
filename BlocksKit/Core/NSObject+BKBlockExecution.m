//
//  NSObject+BKBlockExecution.m
//  BlocksKit
//

#import "NSObject+BKBlockExecution.h"

NS_INLINE dispatch_time_t BKTimeDelay(NSTimeInterval t) {
    return dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * t));
}

@implementation NSObject (BlocksKit)

- (id <NSObject, NSCopying>)bk_performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay
{
	return [self bk_performBlock:block onQueue:dispatch_get_main_queue() afterDelay:delay];
}

+ (id <NSObject, NSCopying>)bk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	return [NSObject bk_performBlock:block onQueue:dispatch_get_main_queue() afterDelay:delay];
}

- (id <NSObject, NSCopying>)bk_performBlockInBackground:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay
{
	return [self bk_performBlock:block onQueue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0) afterDelay:delay];
}

+ (id <NSObject, NSCopying>)bk_performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	return [NSObject bk_performBlock:block onQueue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0) afterDelay:delay];
}

- (id <NSObject, NSCopying>)bk_performBlock:(void (^)(id obj))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay
{
	NSParameterAssert(block != nil);

    return [NSObject bk_dispatchCancellableBlock:^{
        block(self);
    } onQueue:queue afterDelay:delay];
}

+ (id <NSObject, NSCopying>)bk_performBlock:(void (^)(void))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay
{
	NSParameterAssert(block != nil);

    return [NSObject bk_dispatchCancellableBlock:block onQueue:queue afterDelay:delay];
}

+ (id <NSObject, NSCopying>)bk_dispatchCancellableBlock:(void (^)(void))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay
{
    __block BOOL cancelled = NO;
    void (^wrapper)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block();
    };

    dispatch_block_t invocation = ^{ wrapper(NO); };

    if (delay <= 0) {
        dispatch_async(queue, invocation);
    } else {
        dispatch_after(BKTimeDelay(delay), queue, invocation);
    }

    return wrapper;
}

+ (void)bk_cancelBlock:(id <NSObject, NSCopying>)block
{
	NSParameterAssert(block != nil);
	void (^wrapper)(BOOL) = (void(^)(BOOL))block;
	wrapper(YES);
}

@end
