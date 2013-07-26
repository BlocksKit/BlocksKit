//
//  MFMailComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "A2DynamicDelegate.h"
#import "MFMailComposeViewController+BlocksKit.h"
#import "NSObject+A2BlockDelegate.h"

#pragma mark Custom delegate

@interface A2DynamicMFMailComposeViewControllerDelegate : A2DynamicDelegate

@end

@implementation A2DynamicMFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	id realDelegate = self.realDelegate;
	BOOL shouldDismiss = (realDelegate && [realDelegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)]);
	if (shouldDismiss)
		[realDelegate mailComposeController:controller didFinishWithResult:result error:error];

	void (^block)(MFMailComposeViewController *, MFMailComposeResult, NSError *) = [self blockImplementationForMethod:_cmd];
	if (shouldDismiss) {
		if (block) block(controller, result, error);
	} else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
		if ([controller respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
			__weak typeof(controller) weakController = controller;
			[controller dismissViewControllerAnimated:YES completion:^{
				typeof(&*weakController) strongController = weakController;
				if (block) block(strongController, result, error);
			}];
		} else {
#endif
			[controller dismissModalViewControllerAnimated:YES];
			if (block) block(controller, result, error);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
		}
#endif
	}
}

@end

#pragma mark Category

@implementation MFMailComposeViewController (BlocksKit)

@dynamic bk_completionBlock;

+ (void)load
{
	@autoreleasepool {
		[self bk_registerDynamicDelegateNamed:@"mailComposeDelegate" forProtocol:@protocol(MFMailComposeViewControllerDelegate)];
		[self bk_linkDelegateMethods:@{ @"bk_completionBlock": @"mailComposeController:didFinishWithResult:error:" }];
	}
}

@end
