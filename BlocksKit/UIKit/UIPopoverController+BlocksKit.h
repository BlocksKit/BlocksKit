//
//  UIPopoverController+BlocksKit.h
//  %PROJECT
//

/** Block functionality for UIPopoverController.
 
 Created by Alexsander Akers and contributed to BlocksKit. Copyright (c) 2011 Pandamonia LLC. All rights reserved.
 
 @warning UIPopovercontroller is only available on iOS or in a Mac app using Chameleon.
 */
@interface UIPopoverController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nonatomic, copy) BOOL (^shouldDismissBlock)(UIPopoverController *);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly. */
@property (nonatomic, copy) void (^didDismissBlock)(UIPopoverController *);

@end
