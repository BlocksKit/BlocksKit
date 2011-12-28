//
//  UIPopoverController+BlocksKit.m
//  BlocksKit
//
//  Created by Alexsander Akers on 12/27/11.
//  Copyright (c) 2011 Pandamonia LLC. All rights reserved.
//

#import "A2BlockDelegate+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "UIPopoverController+BlocksKit.h"

#pragma mark - Delegate

@interface A2DynamicUIPopoverControllerDelegate : A2DynamicDelegate <UIPopoverControllerDelegate>

@end

@implementation A2DynamicUIPopoverControllerDelegate

- (BOOL) popoverControllerShouldDismissPopover: (UIPopoverController *) popoverController
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector: @selector(popoverControllerShouldDismissPopover:)])
		should &= [realDelegate popoverControllerShouldDismissPopover: popoverController];
	
	BOOL (^block)(UIPopoverController *) = [self blockImplementationForMethod: _cmd];
	if (block) should &= block(popoverController);
	
	return should;
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector: @selector(popoverControllerDidDismissPopover:)])
		[realDelegate popoverControllerDidDismissPopover: popoverController];
	
	void (^block)(UIPopoverController *) = [self blockImplementationForMethod: _cmd];
	if (block) block(popoverController);
}

@end

#pragma mark - Category

@implementation UIPopoverController (BlocksKit)

@dynamic didDismissBlock, shouldDismissBlock;

+ (void) load
{
	@autoreleasepool
	{
		[self registerDynamicDelegate];
		[self linkCategoryBlockProperty: @"didDismissBlock" withDelegateMethod: @selector(popoverControllerDidDismissPopover:)];
		[self linkCategoryBlockProperty: @"shouldDismissBlock" withDelegateMethod: @selector(popoverControllerShouldDismissPopover:)];
	}
}

@end
