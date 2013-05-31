//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** Block functionality for UIGestureRecognizer.

 Use of the delay property is pretty straightforward, although
 cancellation might be a little harder to swallow.  An example
 follows:
	 UITapGestureRecognizer *singleTap = [UITapGestureRecognizer recognizerWithHandler:^(id sender) {
		 NSLog(@"Single tap.");
	 } delay:0.18];
	 [self addGestureRecognizer:singleTap];
 
	 UITapGestureRecognizer *doubleTap = [UITapGestureRecognizer recognizerWithHandler:^(id sender) {
		[singleTap cancel];
		NSLog(@"Double tap.");
	 }];
	 doubleTap.numberOfTapsRequired = 2;
	 [self addGestureRecognizer:doubleTap];

 Believe it or not, the above code is fully memory-safe and efficient.  Eagle-eyed coders
 will notice that this setup emulates UIGestureRecognizer's requireGestureRecognizerToFail:,
 and, yes, it totally apes it.  Not only is this setup much faster on the user's end of
 things, it is more flexible and allows for much more complicated setups.

 Includes code by the following:

 - [Kevin O'Neill](https://github.com/kevinoneill)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @warning UIGestureRecognizer is only available on a platform with UIKit.
 
 @warning It is not recommended to use the Apple-supplied locationInView and state
 methods on a *delayed* block-backed gesture recognizer, as these properties are
 likely to have been cleared by the time by the block fires.  It is instead recommended
 to use the arguments provided to the block.
 */

@interface UIGestureRecognizer (BlocksKit)

/** An autoreleased gesture recognizer that will, on firing, call
 the given block asynchronously after a number of seconds.

 @return An autoreleased instance of a concrete UIGestureRecognizer subclass, or `nil`.
 @param block The block which handles an executed gesture.
 @param delay A number of seconds after which the block will fire.
 */
+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay;

/** Initializes an allocated gesture recognizer that will call the given block
 after a given delay.
 
 An alternative to the designated initializer.
 
 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 @param delay A number of seconds after which the block will fire.
 */
- (id)initWithHandler:(BKGestureRecognizerBlock)block delay:(NSTimeInterval)delay;

/** An autoreleased gesture recognizer that will call the given block.
 
 For convenience and compatibility reasons, this method is indentical
 to using recognizerWithHandler:delay: with a delay of 0.0.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer
 subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (id)recognizerWithHandler:(BKGestureRecognizerBlock)block;

/** Initializes an allocated gesture recognizer that will call the given block.
 
 This method is indentical to calling initWithHandler:delay: with a delay of 0.0.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (id)initWithHandler:(BKGestureRecognizerBlock)block;

/** Allows the block that will be fired by the gesture recognizer
 to be modified after the fact.
 */
@property (nonatomic, copy) BKGestureRecognizerBlock handler;

/** Allows the length of the delay after which the gesture
 recognizer will be fired to modify. */
@property (nonatomic) NSTimeInterval handlerDelay;

/** Allows the length of the delay after which the gesture
 recognizer will be fired to modify.
 
 @warning Due to a collision with an internal method in
 UILongPressGestureRecognizer, this method was replaced
 with handlerDelay starting in BlocksKit 1.0.5.
 
 */
@property (nonatomic) NSTimeInterval delay DEPRECATED_ATTRIBUTE_M("Use handlerDelay");

/** If the recognizer happens to be fired, calling this method
 will stop it from firing, but only if a delay is set.

 @warning This method is not for arbitrarily canceling the
 firing of a recognizer, but will only function for a block
 handler *after the recognizer has already been fired*.  Be
 sure to make your delay times accomodate this likelihood.
 */
- (void)cancel;

@end
