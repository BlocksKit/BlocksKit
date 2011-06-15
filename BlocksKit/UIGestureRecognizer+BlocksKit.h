//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

#import "BlocksKit_Globals.h"

/** Block initialization for UIGestureRecognizer.

 @warning UIGestureRecognizer is only available on iOS or in a Mac app using Chameleon.
 
 Includes code by the following:
 
 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.
 */

@interface UIGestureRecognizer (BlocksKit)

/** An autoreleased gesture recognizer that will, on firing, call
 the given block asynchronously after a number of seconds.

 @return An autoreleased instance of a concrete UIGestureRecognizer subclass, or `nil`.
 @param block The block which handles an executed gesture.
 @param delay A number of seconds after which the block will fire.
 */
+ (id)recognizerWithHandler:(BKSenderBlock)block delay:(NSTimeInterval)delay;

/** Initializes an allocated gesture recognizer that will call the given block
 after a given delay.
 
 An alternative to the designated initializer.
 
 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 @param delay A number of seconds after which the block will fire.
 */
- (id)initWithHandler:(BKSenderBlock)block delay:(NSTimeInterval)delay;

/** An autoreleased gesture recognizer that will call the given block.
 
 For convenience and compatibility reasons, this method is indentical
 to using recognizerWithHandler:delay: with a delay of 0.0.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer
 subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (id)recognizerWithHandler:(BKSenderBlock)block;

/** Initializes an allocated gesture recognizer that will call the given block.
 
 This method is indentical to calling initWithHandler:delay: with a delay of 0.0.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (id)initWithHandler:(BKSenderBlock)block;

/** Allows the block that will be fired by the gesture recognizer
 to be modified after the fact.
 */
@property (copy) BKSenderBlock handler;

/** Allows the length of the delay after which the gesture
 recognizer will be fired to modify.
 */
@property (assign) NSTimeInterval delay;

/** If the recognizer happens to be fired, calling this method
 will stop it from firing, but only if a delay is set.
 */
- (void)cancel;

@end