//
//  UIPopoverController+BlocksKit.h
//  BlocksKit
//

#import "BKGlobals.h"

/** Block functionality for UIPopoverController.
 
 Created by [Alexsander Akers](https://github.com/a2) and contributed to BlocksKit.
 
 @warning UIPopovercontroller is only available on a platform with UIKit.
 */
@interface UIPopoverController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nonatomic, copy) BOOL (^shouldDismissBlock)(UIPopoverController *);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly. */
@property (nonatomic, copy) void (^didDismissBlock)(UIPopoverController *);

@end
