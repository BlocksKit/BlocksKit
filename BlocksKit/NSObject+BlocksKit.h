//
//  NSObject+BlocksKit.h
//  BlocksKit
//
//  Created by Zachary Waldowski on 5/17/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

/** Block execution on *any* object.

 This category overhauls the `performSelector:` utilities on
 NSObject to instead use blocks.  Not only are the blocks performed
 extremely speedily, thread-safely, and asynchronously using
 Grand Central Dispatch, but each convenience method also returns
 a pointer that can be used to cancel the execution before it happens!

 @warning *Important:* Use of the **self** reference in a block will
 reference the current implementation context.  The first argument,
 `obj`, should be used instead.

 Includes code by the following:

 - Peter Steinberger. <https://github.com/steipete>.   2011. MIT.
 - Zach Waldowski.    <https://github.com/zwaldowski>. 2011. MIT.
 */
@interface NSObject (BlocksKit)

/** Executes a block after a given delay on the reciever.
 
 Block execution is very useful, particularly for small events that you would like delayed.

     [object performBlock:^(){
       [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
     } afterDelay:0.5f];
 
 @param block A single-argument code block, where `obj` is the reciever.
 @param delay A measure in seconds.
 @return Returns a pointer to the block that may or may not execute the given block.
 */
- (id)performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay;

/** Performs a block on the current object using an
 
 @param block A single-argument code block, where `obj` is the reciever.
 @param object Any object for use in the block.
 @param delay A measure in seconds.
 @return Returns a pointer to the block that may or may not execute the given block.
 */
- (id)performBlock:(void (^)(id obj, id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;

/** Executes a block after a given delay.
 
 This class method is functionally identical to its instance method version.  It still executes
 asynchronously via GCD.  However, the current context is not passed so that the block is performed
 in a general context.
 
 For example, in a AudioServices abstraction class, I (zwaldowski) have this code:
     -(void)dealloc {
       [NSObject performBlock:^(void) {
         AudioServicesDisposeSystemSoundID(_soundID);
       } afterDelay:3.0];
       [super dealloc];
     }
 By the time the block gets executed, it is a foregone conclusion that the object will be disposed of,
 so it would be both useless and dangerous to have a reference to `obj` around.
 
 @see performBlock:afterDelay:
 @param block A code block with **NO** reciever.
 @param delay A measure in seconds.
 @return Returns a pointer to the block that may or may not execute the given block.
 */
+ (id)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

/** Executes a block using an object after a given delay.
 
 Like the other block-based class method, this is identical to its instance method
 with the exception that it does not have a reference to a reciever.
 
 @see performBlock:withObject:afterDelay:
 @param block A single-argument code block, with **NO** reciever.
 @param object Any object for use in the block.
 @param delay A measure in seconds.
 @return Returns the object if found, `nil` otherwise.
 */
+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay;

/** Cancels the potential execution of a block.
 
 @warning *Important:* It is not recommended to try and cancel a block executed
 with no delay (a delay of 0.0).  While it it still possible to catch the block
 before GCD has executed it, it has likely already been executed and disposed of.
 
 @param block A pointer to a containing block, as returned from one of the
 `performBlock` selectors.
 */
+ (void)cancelBlock:(id)block;

@end