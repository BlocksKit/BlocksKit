//
//  UIPopoverController+BlocksKit.h
//  BlocksKit
//
//  Created by Alexsander Akers on 12/27/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPopoverController (BlocksKit)

/** The block to be called when the popover controller will dismiss the popover. Return NO to prevent the dismissal of the view. */
@property (nonatomic, copy) BOOL (^shouldDismissBlock)(UIPopoverController *);

/** The block to be called when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly. */
@property (nonatomic, copy) void (^didDismissBlock)(UIPopoverController *);

@end
