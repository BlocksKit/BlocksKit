//
//  MFMailComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMailComposeViewController+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicMFMailComposeViewControllerDelegate : A2DynamicDelegate
@end

@implementation A2DynamicMFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	id realDelegate = self.realDelegate;
	if (realDelegate && [realDelegate respondsToSelector:@selector(mailComposeController:didFinishWithResult:error:)])
		[realDelegate mailComposeController:controller didFinishWithResult:result error:error];
	else
		[controller dismissModalViewControllerAnimated:YES];

	void(^block)(MFMailComposeViewController *, MFMailComposeResult, NSError *) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(controller, result, error);
}

@end

#pragma mark Category

@implementation MFMailComposeViewController (BlocksKit)

@dynamic completionBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegateNamed:@"mailComposeDelegate" forProtocol:@protocol(MFMailComposeViewControllerDelegate)];
		[self linkCategoryBlockProperty:@"completionBlock" withDelegateMethod:@selector(mailComposeController:didFinishWithResult:error:)];
	}
}

@end