//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (BlocksKit)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)inBlock repeats:(BOOL)inRepeats {
    BKTimerBlock block = [inBlock copy];
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:block repeats:inRepeats];
    [block release];
    return ret;
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)inBlock repeats:(BOOL)inRepeats {
    BKTimerBlock block = [inBlock copy];
    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:block repeats:inRepeats];
    [block release];
    return ret;
}

+ (void)_executeBlockFromTimer:(NSTimer *)aTimer {
    BKTimerBlock block = [aTimer userInfo];
    NSTimeInterval time = [aTimer timeInterval];
    if (block) block(time);
}

@end