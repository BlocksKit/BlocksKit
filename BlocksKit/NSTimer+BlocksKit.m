//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (BlocksKit)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self scheduledTimerWithTimeInterval: inTimeInterval target: self selector: @selector(bk_executeBlockFromTimer:) userInfo: [block copy] repeats: inRepeats];
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self timerWithTimeInterval: inTimeInterval target: self selector: @selector(bk_executeBlockFromTimer:) userInfo: [block copy] repeats: inRepeats];
}

+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer {
	BKTimerBlock block = [aTimer userInfo];
	if (block) block(aTimer);
}

@end
