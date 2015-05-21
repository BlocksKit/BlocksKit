//
//  UIBarButtonItem+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

/** Block event initialization for UIBarButtonItem.

 This set of extensions has near-drop-in replacements
 for the standard set of UIBarButton item initializations,
 using a block handler instead of a target/selector.

 Includes code by the following:

 - [Kevin O'Neill](https://github.com/kevinoneill)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @warning UIBarButtonItem is only available on a platform with UIKit.
 */
@interface UIBarButtonItem (BlocksKit)

/** Creates and returns a configured item containing the specified system item.

 @return Newly initialized item with the specified properties.
 @param systemItem The system item to use as the item representation. One of the constants defined in UIBarButtonSystemItem.
 @param action The block that gets fired on the button press.
 */
- (instancetype)bk_initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(id sender))action NS_REPLACES_RECEIVER;

/** Creates and returns a configured item using the specified image and style.
 
 @return Newly initialized item with the specified properties.
 @param image The item’s image. If nil an image is not displayed.
 If this image is too large to fit on the bar, it is scaled to fit
 The size of a toolbar and navigation bar image is 20 x 20 points.
 @param style The style of the item. One of the constants defined in UIBarButtonItemStyle.
 @param action The block that gets fired on the button press.
 */
- (instancetype)bk_initWithImage:(nullable UIImage *)image style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action NS_REPLACES_RECEIVER;

/** Creates and returns a configured item using the specified image and style.

 @return Newly initialized item with the specified properties.
 @param image The item’s image. If nil an image is not displayed.
 @param landscapeImagePhone The image to be used for the item in landscape bars in the UIUserInterfaceIdiomPhone idiom.
 @param style The style of the item. One of the constants defined in UIBarButtonItemStyle.
 @param action The block that gets fired on the button press.
 */
- (instancetype)bk_initWithImage:(nullable UIImage *)image landscapeImagePhone:(nullable UIImage *)landscapeImagePhone style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action NS_REPLACES_RECEIVER;

/** Creates and returns a configured item using the specified text and style.
 
 @return Newly initialized item with the specified properties.
 @param title The text displayed on the button item.
 @param style The style of the item. One of the constants defined in UIBarButtonItemStyle.
 @param action The block that gets fired on the button press.
 */
- (instancetype)bk_initWithTitle:(nullable NSString *)title style:(UIBarButtonItemStyle)style handler:(void (^)(id sender))action NS_REPLACES_RECEIVER;

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif
