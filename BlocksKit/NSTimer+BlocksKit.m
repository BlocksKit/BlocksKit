//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (BlocksKit)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[[block copy] autorelease] repeats:inRepeats];
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
	NSParameterAssert(block);
	return [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[[block copy] autorelease] repeats:inRepeats];
}

+ (void)_executeBlockFromTimer:(NSTimer *)aTimer {
	NSTimeInterval time = [aTimer timeInterval];
	((BKTimerBlock)aTimer.userInfo)(time);
}

@end