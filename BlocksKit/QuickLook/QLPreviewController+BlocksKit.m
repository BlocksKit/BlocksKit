//
//  QLPreviewController+BlocksKit.m
//  BlocksKit
//

#import "QLPreviewController+BlocksKit.h"
#import "A2DynamicDelegate.h"
#import "NSObject+A2DynamicDelegate.h"
#import "NSObject+A2BlockDelegate.h"

#pragma mark Custom delegate

@interface A2DynamicQLPreviewControllerDelegate : A2DynamicDelegate <QLPreviewControllerDelegate>

@end

@implementation A2DynamicQLPreviewControllerDelegate

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView **)view
{
	CGRect should = CGRectZero;

	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(previewController:frameForPreviewItem:inSourceView:)])
		should = [realDelegate previewController:controller frameForPreviewItem:item inSourceView:view];

	CGRect (^block)(QLPreviewController *, id<QLPreviewItem>, UIView **) = [self blockImplementationForMethod:_cmd];
	if (block)
		should = block(controller, item, view);

	return should;
}

- (UIImage *)previewController:(QLPreviewController *)controller transitionImageForPreviewItem:(id<QLPreviewItem>)item contentRect:(CGRect *)contentRect
{
	UIImage *should = nil;

	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(previewController:transitionImageForPreviewItem:contentRect:)])
		should = [realDelegate previewController:controller transitionImageForPreviewItem:item contentRect:contentRect];

	UIImage *(^block)(QLPreviewController *, id<QLPreviewItem>, CGRect *) = [self blockImplementationForMethod:_cmd];
	if (block)
		should = block(controller, item, contentRect);

	return should;
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item
{
	BOOL should = YES;

	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(previewController:shouldOpenURL:forPreviewItem:)])
		should = [realDelegate previewController:controller shouldOpenURL:url forPreviewItem:item];

	BOOL (^block)(QLPreviewController *, NSURL *, id<QLPreviewItem>) = [self blockImplementationForMethod:_cmd];
	if (block)
		should = block(controller, url, item);

	return should;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(previewControllerWillDismiss:)])
		[realDelegate previewControllerWillDismiss:controller];

	void (^block)(QLPreviewController *) = [self blockImplementationForMethod:_cmd];
	if (block) block(controller);
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(previewControllerDidDismiss:)])
		[realDelegate previewControllerDidDismiss:controller];

	void (^block)(QLPreviewController *) = [self blockImplementationForMethod:_cmd];
	if (block) block(controller);
}

@end

#pragma mark - Category

@implementation QLPreviewController (BlocksKit)

@dynamic bk_frameForPreviewItem, bk_transitionImageForPreviewItem, bk_shouldOpenURLForPreviewItem, bk_willDismissBlock, bk_didDismissBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegate];
		[self bk_linkDelegateMethods:@{
									   @"bk_frameForPreviewItem": @"previewController:frameForPreviewItem:inSourceView:",
									   @"bk_transitionImageForPreviewItem": @"previewController:transitionImageForPreviewItem:contentRect:",
									   @"bk_shouldOpenURLForPreviewItem": @"previewController:shouldOpenURL:forPreviewItem:",
									   @"bk_willDismissBlock": @"previewControllerWillDismiss:",
									   @"bk_didDismissBlock": @"previewControllerDidDismiss:"
									   }];
	}
}

@end
