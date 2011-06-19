//
//  NSTimer+BlocksKit.m
//  BlocksKit
//

#import "NSTimer+BlocksKit.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (BlocksKit)

#if __has_feature(objc_arc)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
    return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(BKTimerBlock)block repeats:(BOOL)inRepeats {
    return [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

#else

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

#endif

+ (void)_executeBlockFromTimer:(NSTimer *)aTimer {
    BKTimerBlock block = [aTimer userInfo];
    NSTimeInterval time = [aTimer timeInterval];
    if (block) block(time);
}

@end