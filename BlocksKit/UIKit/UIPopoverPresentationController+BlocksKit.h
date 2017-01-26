#import "BKDefines.h"
#import <UIKit/UIKit.h>

@interface UIPopoverPresentationController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nullable, nonatomic, copy, setter = bk_setShouldDismissBlock:) BOOL (^bk_shouldDismissBlock)(UIPopoverPresentationController * __nonnull popoverPresentationController);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when - dismissModalViewControllerAnimated: is called directly. */
@property (nullable, nonatomic, copy, setter = bk_setDidDismissBlock:) void (^bk_didDismissBlock)(UIPopoverPresentationController  * __nonnull popoverPresentationController);

/** The block to be called in response to interface changes that require a new size for the popover. */
@property (nullable, nonatomic, copy, setter = bk_setWillRepositionPopoverToRectInViewBlock:) void (^bk_willRepositionPopoverToRectInViewBlock)(UIPopoverPresentationController  * __nonnull popoverPresentationController, CGRect * __nonnull rect, UIView  * __nonnull * __nonnull view);

@end
