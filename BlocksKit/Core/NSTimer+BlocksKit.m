//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)

+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer;

@end

@implementation NSTimer (BlocksKit)

+ (id)bk_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimeInterval time))block repeats:(BOOL)inRepeats
{
	NSParameterAssert(block != nil);
	return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(bk_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (id)bk_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimeInterval time))block repeats:(BOOL)inRepeats
{
	NSParameterAssert(block != nil);
	return [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(bk_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (void)bk_executeBlockFromTimer:(NSTimer *)aTimer {
	NSTimeInterval time = [aTimer timeInterval];
	void (^block)(NSTimeInterval) = [aTimer userInfo];
	if (block) block(time);
}

@end
