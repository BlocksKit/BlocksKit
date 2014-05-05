//
//  UIGestureRecognizer+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

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
+ (id)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay;

/** Initializes an allocated gesture recognizer that will call the given block
 after a given delay.
 
 An alternative to the designated initializer.
 
 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 @param delay A number of seconds after which the block will fire.
 */
- (id)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block delay:(NSTimeInterval)delay NS_REPLACES_RECEIVER;

/** An autoreleased gesture recognizer that will call the given block.
 
 For convenience and compatibility reasons, this method is indentical
 to using recognizerWithHandler:delay: with a delay of 0.0.
  
 @return An initialized and autoreleased instance of a concrete UIGestureRecognizer
 subclass, or `nil`.
 @param block The block which handles an executed gesture.
 */
+ (id)bk_recognizerWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block;

/** Initializes an allocated gesture recognizer that will call the given block.
 
 This method is indentical to calling initWithHandler:delay: with a delay of 0.0.

 @return An initialized instance of a concrete UIGestureRecognizer subclass or `nil`.
 @param block The block which handles an executed gesture.
 */
- (id)bk_initWithHandler:(void (^)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location))block NS_REPLACES_RECEIVER;

/** Allows the block that will be fired by the gesture recognizer
 to be modified after the fact.
 */
@property (nonatomic, copy, setter = bk_setHandler:) void (^bk_handler)(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location);

/** Allows the length of the delay after which the gesture
 recognizer will be fired to modify. */
@property (nonatomic, setter = bk_setHandlerDelay:) NSTimeInterval bk_handlerDelay;

/** If the recognizer happens to be fired, calling this method
 will stop it from firing, but only if a delay is set.

 @warning This method is not for arbitrarily canceling the
 firing of a recognizer, but will only function for a block
 handler *after the recognizer has already been fired*.  Be
 sure to make your delay times accomodate this likelihood.
 */
- (void)bk_cancel;


///** The block to be fired before the alert view will show. */
//@property (nonatomic, copy, setter = bk_setWillShowBlock:) void (^bk_willShowBlock)(UIAlertView *alertView);
//
///** The block to be fired when the alert view shows. */
//@property (nonatomic, copy, setter = bk_setDidShowBlock:) void (^bk_didShowBlock)(UIAlertView *alertView);
//
///** The block to be fired before the alert view will dismiss. */
//@property (nonatomic, copy, setter = bk_setWillDismissBlock:) void (^bk_willDismissBlock)(UIAlertView *alertView, NSInteger buttonIndex);
//
///** The block to be fired after the alert view dismisses. */
//@property (nonatomic, copy, setter = bk_setDidDismissBlock:) void (^bk_didDismissBlock)(UIAlertView *alertView, NSInteger buttonIndex);
//
///** The block to be fired to determine whether the first non-cancel should be enabled */
//@property (nonatomic, copy, setter = bk_SetShouldEnableFirstOtherButtonBlock:) BOOL (^bk_shouldEnableFirstOtherButtonBlock)(UIAlertView *alertView) NS_AVAILABLE_IOS(5_0);


/** The block to be fired when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed */
@property (nonatomic, copy, setter = bk_SetShouldBeginBlock:) BOOL (^bk_shouldBeginBlock)(UIGestureRecognizer* gestureRecognizer);


/** The block to be fired when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
 return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)

 note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
 */
@property (nonatomic, copy, setter = bk_SetShouldRecognizeSimultaneouslyBlock:) BOOL (^bk_shouldRecognizeSimultaneouslyBlock)(UIGestureRecognizer* gestureRecognizer, UIGestureRecognizer* otherGestureRecognizer);

/** The block to be fired once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
 return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer

 note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
 */
@property (nonatomic, copy, setter = bk_SetShouldRequireFailureOfGestureRecognizerBlock:) BOOL (^bk_shouldRequireFailureOfGestureRecognizerBlock)(UIGestureRecognizer* gestureRecognizer, UIGestureRecognizer* otherGestureRecognizer) NS_AVAILABLE_IOS(7_0);
@property (nonatomic, copy, setter = bk_SetShouldBeRequiredToFailByGestureRecognizerBlock:) BOOL (^bk_shouldBeRequiredToFailByGestureRecognizerBlock)(UIGestureRecognizer* gestureRecognizer, UIGestureRecognizer* otherGestureRecognizer) NS_AVAILABLE_IOS(7_0);

/** The block to be fired before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch */
@property (nonatomic, copy, setter = bk_SetShouldReceiveTouchBlock:) BOOL (^bk_shouldReceiveTouchBlock)(UIGestureRecognizer* gestureRecognizer, UITouch* touch);

@end
