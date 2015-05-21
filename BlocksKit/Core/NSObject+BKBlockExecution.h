//
//  NSObject+BKBlockExecution.h
//  BlocksKit
//

#import <Foundation/Foundation.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

/** Block execution on *any* object.

 This category overhauls the `performSelector:` utilities on
 NSObject to instead use blocks.  Not only are the blocks performed
 extremely speedily, thread-safely, and asynchronously using
 Grand Central Dispatch, but each convenience method also returns
 a pointer that can be used to cancel the execution before it happens!

 Includes code by the following:

 - [Peter Steinberger](https://github.com/steipete)
 - [Zach Waldowski](https://github.com/zwaldowski)

 */
@interface NSObject (BKBlockExecution)

/** Executes a block after a given delay on the reciever.

	[array performBlock:^(id obj) {
	  [obj addObject:self];
	  [self release];
	} afterDelay:0.5f];

 @warning *Important:* Use of the **self** reference in a block will
 reference the current implementation context.  The block argument,
 `obj`, should be used instead.

 @param block A single-argument code block, where `obj` is the reciever.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
- (id <NSObject, NSCopying>)bk_performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay;

/** Executes a block after a given delay.

 This class method is functionally identical to its instance method version.  It still executes
 asynchronously via GCD.  However, the current context is not passed so that the block is performed
 in a general context.

 Block execution is very useful, particularly for small events that you would like delayed.

	[object performBlock:^{
	  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	} afterDelay:0.5f];

 @see performBlock:afterDelay:
 @param block A code block.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
+ (id <NSObject, NSCopying>)bk_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/** Executes a block in the background after a given delay on the receiver.
 
 This class method is functionally identical to `- (id)bk_performBlock:afterDelay:`,
 except the block will be performed on a background thread instead of the main thread.
 
 @see performBlock:afterDelay:
 @param block A code block.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
- (id <NSObject, NSCopying>)bk_performBlockInBackground:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay;

/** Executes a block in the background after a given delay.
 
 This class method is functionally identical to `+ (id)bk_performBlock:afterDelay:`, 
 except the block will be performed on a background thread instead of the main thread.
 
 @see performBlock:afterDelay:
 @param block A code block.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
+ (id <NSObject, NSCopying>)bk_performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/** Executes a block in the background after a given delay.
 
 This class method is functionally identical to `+ (id)bk_performBlock:afterDelay:`,
 except the block will be performed on the specified thread instead of the main thread.
 
 @see performBlock:afterDelay:
 @param block A code block.
 @param queue A background queue.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
+ (id <NSObject, NSCopying>)bk_performBlock:(void (^)(void))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay;

/** Executes a block in the background after a given delay.
 
 This class method is functionally identical to `- (id)bk_performBlock:afterDelay:`,
 except the block will be performed on the specified thread instead of the main thread.
 
 @see performBlock:afterDelay:
 @param block A code block.
 @param queue A background queue.
 @param delay A measure in seconds.
 @return An opaque, temporary token that may be used to cancel execution.
 */
- (id <NSObject, NSCopying>)bk_performBlock:(void (^)(id obj))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay;

/** Cancels the potential execution of a block.

 @warning *Important:* It is not recommended to cancel a block executed
 with a delay of @c 0.

 @param block A cancellation token, as returned from one of the `performBlock`
 selectors.
 */
+ (void)bk_cancelBlock:(id <NSObject, NSCopying>)block;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif
