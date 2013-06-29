//
//  UIView+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

/** Convenience on-touch methods for UIView.

 Includes code by the following:

 - Kevin O'Neill. <https://github.com/kevinoneill>. 2011. BSD.
 - Jake Marsh. <https://github.com/jakemarsh>. 2011. 
 - Zach Waldowski. <https://github.com/zwaldowski>. 2011.

 @warning UIView is only available on a platform with UIKit.
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
- (void)bk_whenTouches:(NSUInteger)numberOfTouches tapped:(NSUInteger)numberOfTaps handler:(void (^)(void))block;

/** Adds a recognizer for one finger tapping once.
 
 @warning This method has an _additive_ effect. Do not call it multiple
 times to set-up or tear-down. The view will discard the gesture recognizer
 on release.

 @param block The handler for the tap recognizer
 @see whenDoubleTapped:
 @see whenTouches:tapped:handler:
 */
- (void)bk_whenTapped:(void (^)(void))block;

/** Adds a recognizer for one finger tapping twice.
 
 @warning This method has an _additive_ effect. Do not call it multiple
 times to set-up or tear-down. The view will discard the gesture recognizer
 on release.
 
 @param block The handler for the tap recognizer
 @see whenTapped:
 @see whenTouches:tapped:handler:
 */
- (void)bk_whenDoubleTapped:(void (^)(void))block;

/** A convenience wrapper that non-recursively loops through the subviews of a view.
 
 @param block A code block that interacts with a UIView sender.
 */
- (void)bk_eachSubview:(void(^)(UIView *subview))block;

/** The block that gets called on a finger down.
 
 Internally, this method overrides the touchesBegan:withEvent:
 selector of UIView and is mechanically similar to
 UIControlEventTouchDown.
 */
@property (nonatomic, copy, setter = bk_setOnTouchDownBlock:) void (^bk_onTouchDownBlock)(NSSet *set, UIEvent *event);

/** The block that gets called on a finger drag.
 
 Internally, this method overrides the touchesMoved:withEvent:
 selector of UIView.
 */
@property (nonatomic, copy, setter = bk_setOnTouchMoveBlock:) void (^bk_onTouchMoveBlock)(NSSet *set, UIEvent *event);

/** The block that gets called on a finger up.
 
 Internally, this method overrides the touchesBegan:withEvent:
 selector of UIView and is mechanically similar to
 UIControlEventTouchCancel.
 */
@property (nonatomic, copy, setter = bk_setOnTouchUpBlock:) void (^bk_onTouchUpBlock)(NSSet *set, UIEvent *event);

@end
