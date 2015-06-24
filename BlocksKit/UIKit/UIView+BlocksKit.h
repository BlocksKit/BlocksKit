//
//  UIView+BlocksKit.h
//  BlocksKit
//

#import "BKDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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
- (void)bk_eachSubview:(void (^)(UIView *subview))block;

@end

NS_ASSUME_NONNULL_END
