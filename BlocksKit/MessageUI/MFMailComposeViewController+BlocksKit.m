//
//  MFMailComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMailComposeViewController+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicMFMailComposeViewControllerDelegate : A2DynamicDelegate
@end

@implementation A2DynamicMFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	id realDelegate = self.realDelegate;
	BOOL shouldDismiss = (realDelegate && [realDelegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)]);
	
	if (shouldDismiss)
		[realDelegate mailComposeController:controller didFinishWithResult:result error:error];

	void(^block)(MFMailComposeViewController *, MFMailComposeResult, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(controller, result, error);
	
	if (!shouldDismiss) {
	        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
	            [controller dismissModalViewControllerAnimated:YES];
                #else
                    [controller dismissViewControllerAnimated:YES completion:nil];
                #endif
		
         }
}

@end

#pragma mark Category

@implementation MFMailComposeViewController (BlocksKit)

@dynamic completionBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegateNamed:@"mailComposeDelegate" forProtocol:@protocol(MFMailComposeViewControllerDelegate)];
		[self linkDelegateMethods: @{ @"completionBlock": @"mailComposeController:didFinishWithResult:error:" }];
	}
}

@end
