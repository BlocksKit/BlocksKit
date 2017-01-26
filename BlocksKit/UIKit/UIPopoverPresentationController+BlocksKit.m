#import "UIPopoverPresentationController+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"

#pragma mark - Delegate

@interface A2DynamicUIPopoverPresentationControllerDelegate : A2DynamicDelegate <UIPopoverPresentationControllerDelegate>

@end

@implementation A2DynamicUIPopoverPresentationControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
	BOOL should = YES;
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(popoverPresentationControllerShouldDismissPopover:)])
		should &= [realDelegate popoverPresentationControllerShouldDismissPopover:popoverPresentationController];
	
	BOOL (^block)(UIPopoverPresentationController *) = [self blockImplementationForMethod:_cmd];
	if (block) should &= block(popoverPresentationController);
	
	return should;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(popoverPresentationControllerDidDismissPopover:)])
		[realDelegate popoverPresentationControllerDidDismissPopover:popoverPresentationController];
	
	void (^block)(UIPopoverPresentationController *) = [self blockImplementationForMethod:_cmd];
	if (block) block(popoverPresentationController);
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
	
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(popoverPresentationController:willRepositionPopoverToRect:inView:)])
		[realDelegate popoverPresentationController:popoverPresentationController willRepositionPopoverToRect:rect inView:view];

	void (^block)(UIPopoverPresentationController *, CGRect *, UIView **) = [self blockImplementationForMethod:_cmd];
	if (block) block(popoverPresentationController, rect, view);
}

@end

#pragma mark - Category

@implementation UIPopoverPresentationController (BlocksKit)

@dynamic bk_didDismissBlock, bk_shouldDismissBlock, bk_willRepositionPopoverToRectInViewBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{ @"bk_shouldDismissBlock" : @"popoverPresentationControllerShouldDismissPopover:",
										@"bk_didDismissBlock" : @"popoverPresentationControllerDidDismissPopover:",
		                                @"bk_willRepositionPopoverToRectInViewBlock" : @"popoverPresentationController:willRepositionPopoverToRect:inView:"
		}];
	}
}

@end
