//
//  NSObject+BKBlockExecution.m
//  BlocksKit
//

#import "NSObject+BKBlockExecution.h"

#define BKTimeDelay(t) dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(NSEC_PER_SEC * t))

@implementation NSObject (BlocksKit)

- (id)bk_performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay
{
	NSParameterAssert(block != nil);

	__block BOOL cancelled = NO;

	void (^wrapper)(BOOL) = ^(BOOL cancel) {
		if (cancel) {
			cancelled = YES;
			return;
		}
		if (!cancelled) block(self);
	};

	dispatch_after(BKTimeDelay(delay), dispatch_get_main_queue(), ^{
		wrapper(NO);
	});

	return [wrapper copy];
}

+ (id)bk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
	NSParameterAssert(block != nil);

	__block BOOL cancelled = NO;

	void (^wrapper)(BOOL) = ^(BOOL cancel) {
		if (cancel) {
			cancelled = YES;
			return;
		}
		if (!cancelled) block();
	};

	dispatch_after(BKTimeDelay(delay), dispatch_get_main_queue(), ^{ wrapper(NO); });

	return [wrapper copy];
}

+ (void)bk_cancelBlock:(id)block
{
	NSParameterAssert(block != nil);
	void (^wrapper)(BOOL) = block;
	wrapper(YES);
}

@end
