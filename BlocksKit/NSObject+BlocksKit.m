//
//  NSObject+BlocksKit.m
//  BlocksKit
//

#import "NSObject+BlocksKit.h"
#import <objc/runtime.h>

typedef void(^BKInternalWrappingBlock)(BOOL);

#define BKTimeDelay(t) dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * t)

@implementation NSObject (BlocksKit)

- (id)performBlock:(BKSenderBlock)block afterDelay:(NSTimeInterval)delay {
	NSParameterAssert(block != nil);
	
	__block BOOL cancelled = NO;
		
	void(^wrapper)(BOOL) = ^(BOOL cancel) {
		if (cancel) {
			cancelled = YES;
			return;
		}
		if (!cancelled) block(self);
	};
	
	dispatch_after(BKTimeDelay(delay), dispatch_get_main_queue(), ^{
		wrapper(NO);
	});
	
	return [[wrapper copy] autorelease];
}

+ (id)performBlock:(BKBlock)block afterDelay:(NSTimeInterval)delay {
	NSParameterAssert(block != nil);
	
	__block BOOL cancelled = NO;
	
	void(^wrapper)(BOOL) = ^(BOOL cancel) {
		if (cancel) {
			cancelled = YES;
			return;
		}
		if (!cancelled) block();
	};
	
	dispatch_after(BKTimeDelay(delay), dispatch_get_main_queue(), ^{ wrapper(NO); });
	
	return [[wrapper copy] autorelease];
}

+ (void)cancelBlock:(id)block {
	NSParameterAssert(block != nil);
	void(^wrapper)(BOOL) = block;
	wrapper(YES);
}

@end