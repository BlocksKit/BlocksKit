//
//  UIPopoverController+BlocksKit.h
//  BlocksKit
//

#import <UIKit/UIKit.h>

/** Block functionality for UIPopoverController.
 
 Created by [Alexsander Akers](https://github.com/a2) and contributed to BlocksKit.
 
 @warning UIPopovercontroller is only available on a platform with UIKit.
 */
@interface UIPopoverController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nonatomic, copy, setter = bk_setShouldDismissBlock:) BOOL (^bk_shouldDismissBlock)(UIPopoverController *popoverController);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly. */
@property (nonatomic, copy, setter = bk_setDidDismissBlock:) void (^bk_didDismissBlock)(UIPopoverController *popoverController);

@end
