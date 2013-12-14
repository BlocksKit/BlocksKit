//
//  MFMessageComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
#import "MFMessageComposeViewController+BlocksKit.h"
#import "NSObject+A2BlockDelegate.h"

#pragma mark Custom delegate

@interface A2DynamicMFMessageComposeViewControllerDelegate : A2DynamicDelegate <MFMessageComposeViewControllerDelegate>

@end

@implementation A2DynamicMFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	id realDelegate = self.realDelegate;
	BOOL shouldDismiss = (realDelegate && [realDelegate respondsToSelector:@selector(messageComposeViewController:didFinishWithResult:)]);
	if (shouldDismiss)
		[realDelegate messageComposeViewController:controller didFinishWithResult:result];

	void (^block)(MFMessageComposeViewController *, MessageComposeResult) = [self blockImplementationForMethod:_cmd];
	if (shouldDismiss) {
		if (block) block(controller, result);
	} else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
		__weak typeof(controller) weakController = controller;
		[controller dismissViewControllerAnimated:YES completion:^{
			typeof(&*weakController) strongController = weakController;
			if (block) block(strongController, result);
		}];
#else
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
		if ([controller respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
			__weak typeof(controller) weakController = controller;
			[controller dismissViewControllerAnimated:YES completion:^{
				typeof(&*weakController) strongController = weakController;
				if (block) block(strongController, result);
			}];
		} else {
#endif
			[controller dismissModalViewControllerAnimated:YES];
			if (block) block(controller, result);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
		}
#endif
#endif
	}
}

@end

#pragma mark - Category

@implementation MFMessageComposeViewController (BlocksKit)

@dynamic bk_completionBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegateNamed:@"messageComposeDelegate"];
		[self bk_linkDelegateMethods:@{ @"bk_completionBlock": @"messageComposeViewController:didFinishWithResult:" }];
	}
}

@end
