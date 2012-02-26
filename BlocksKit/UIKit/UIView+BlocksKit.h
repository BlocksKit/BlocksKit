//
//  UIView+BlocksKit.h
//  %PROJECT
//

#import "BKGlobals.h"

/** Convenience on-touch methods for UIView.

 Includes code by the following:

 - Kevin O'Neill.  <https://github.com/kevinoneill>. 2011. BSD.
 - Jake Marsh.	 <https://github.com/jakemarsh>.   2011. 
 - Zach Waldowski. <https://github.com/zwaldowski>.  2011. MIT.

 @warning UIView is only available on iOS or in a Mac app using Chameleon.
 */
@interface UIView (BlocksKit)

/** Abstract creation of a block-backed UITapGestureRecognizer.

 This method allows for the recognition of any arbitrary number
 of fingers tapping any number of times on a view.  An instance
 of UITapGesture recognizer is allocated for the block and added
 to the recieving view.
 
 @warning This method has an _additive_ effect. Do not call it multiple
 times to set-up or tear-down. The view will discard the gesture recognizer
 on release.

 @param numberOfTouches The number of fingers tapping that will trigger the block.
 @param numberOfTaps The number of taps required to trigger the block.
 @param block The handler for the UITapGestureRecognizer
 @see whenTapped:
 @see whenDoubleTapped:
 */
- (void)whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(BKBlock)block;

/** Adds a recognizer for one finger tapping once.
 
 @warning This method has an _additive_ effect. Do not call it multiple
 times to set-up or tear-down. The view will discard the gesture recognizer
 on release.

 @param block The handler for the tap recognizer
 @see whenDoubleTapped:
 @see whenTouches:tapped:handler:
 */
- (void)whenTapped:(BKBlock)block;

/** Adds a recognizer for one finger tapping twice.
 
 @warning This method has an _additive_ effect. Do not call it multiple
 times to set-up or tear-down. The view will discard the gesture recognizer
 on release.
 
 @param block The handler for the tap recognizer
 @see whenTapped:
 @see whenTouches:tapped:handler:
 */
- (void)whenDoubleTapped:(BKBlock)block;

/** A convenience wrapper that non-recursively loops through the subviews of a view.
 
 @param block A code block that interacts with a UIView sender.
 */
- (void)eachSubview:(void(^)(UIView *))block;

/** The block that gets called on a finger down.
 
 Internally, this method overrides the touchesBegan:withEvent:
 selector of UIView and is mechanically similar to
 UIControlEventTouchDown.
 */
@property (nonatomic, copy) BKTouchBlock onTouchDownBlock;

/** The block that gets called on a finger drag.
 
 Internally, this method overrides the touchesMoved:withEvent:
 selector of UIView.
 */
@property (nonatomic, copy) BKTouchBlock onTouchMoveBlock;

/** The block that gets called on a finger up.
 
 Internally, this method overrides the touchesBegan:withEvent:
 selector of UIView and is mechanically similar to
 UIControlEventTouchCancel.
 */
@property (nonatomic, copy) BKTouchBlock onTouchUpBlock;

@end
