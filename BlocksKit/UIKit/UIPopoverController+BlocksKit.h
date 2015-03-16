//
//  UIPopoverController+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

#if __has_feature(nullability) // Xcode 6.3+
#pragma clang assume_nonnull begin
#else
#define nullable
#define __nullable
#endif

/** Block functionality for UIPopoverController.
 
 Created by [Alexsander Akers](https://github.com/a2) and contributed to BlocksKit.
 
 @warning UIPopovercontroller is only available on a platform with UIKit.
 */
@interface UIPopoverController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nonatomic, copy, setter = bk_setShouldDismissBlock:, nullable) BOOL (^bk_shouldDismissBlock)(UIPopoverController *popoverController);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly. */
@property (nonatomic, copy, setter = bk_setDidDismissBlock:, nullable) void (^bk_didDismissBlock)(UIPopoverController *popoverController);

@end

#if __has_feature(nullability)
#pragma clang assume_nonnull end
#endif
