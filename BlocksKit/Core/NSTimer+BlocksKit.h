//
//  NSTimer+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Simple category on NSTimer to give it blocks capability.

 Created by [Jiva DeVoe](https://github.com/jivadevoe) as `NSTimer-Blocks`.
*/
@interface NSTimer (BlocksKit)

/** Creates a new @c NSTimer object using the specified handler, schedules it on
 * the current run loop, and returns it.
 *
 * @param seconds For a repeating timer, the seconds between firings of the
 * timer. If seconds is less than or equal to @c 0.0, @c 0.1 is used instead.
 * @param repeats If @c YES, the timer will repeatedly reschedule itself until
 * invalidated. If @c NO, the timer will be invalidated after it fires.
 * @param block The code unit to execute when the timer fires.
 * @return A new @c NSTimer object, configured according to the specified parameters.
 */
+ (instancetype)bk_scheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;

/** Creates and returns a new @c NSTimer object using the specified handler.
 *
 * You must add the new timer to a run loop, using @c addTimer:forMode:. Upon
 * firing, the timer fires the block. If the timer is configured to repeat,
 * there is no need to subsequently re-add the timer to the run loop.
 *
 * @param seconds For a repeating timer, the seconds between firings of the
 * timer. If seconds is less than or equal to @c 0.0, @c 0.1 is used instead.
 * @param repeats If @c YES, the timer will repeatedly reschedule itself until
 * invalidated. If @c NO, the timer will be invalidated after it fires.
 * @param block The code unit to execute when the timer fires.
 * @return A new @c NSTimer object, configured according to the specified parameters.
 */
+ (instancetype)bk_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block;

@end

@interface NSTimer (BlocksKit_Deprecated)

+ (instancetype)bk_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats DEPRECATED_MSG_ATTRIBUTE("Replaced with -bk_performAfterDelay:usingBlock:");
+ (instancetype)bk_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats DEPRECATED_MSG_ATTRIBUTE("Replaced with -bk_performAfterDelay:usingBlock:");

@end

NS_ASSUME_NONNULL_END
