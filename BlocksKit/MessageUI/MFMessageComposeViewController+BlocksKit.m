//
//  MFMessageComposeViewController+BlocksKit.m
//  BlocksKit
//

#import "MFMessageComposeViewController+BlocksKit.h"
#import "A2BlockDelegate+BlocksKit.h"

#pragma mark Custom delegate

@interface A2DynamicMFMessageComposeViewControllerDelegate : A2DynamicDelegate
@end

@implementation A2DynamicMFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	id realDelegate = self.realDelegate;
	BOOL shouldDismiss = (realDelegate && [realDelegate respondsToSelector:@selector(messageComposeViewController:didFinishWithResult:)]);
	if (shouldDismiss)
		[realDelegate messageComposeViewController:controller didFinishWithResult:result];
	
	void(^block)(MFMessageComposeViewController *, MessageComposeResult) = [self blockImplementationForMethod:_cmd];
	if (block)
		block(controller, result);
	
	if (!shouldDismiss)
		[controller dismissModalViewControllerAnimated:YES];
}

@end

#pragma mark - Category

@implementation MFMessageComposeViewController (BlocksKit)

@dynamic completionBlock;

+ (void)load {
	@autoreleasepool {
		[self registerDynamicDelegateNamed:@"messageComposeDelegate" forProtocol:@protocol(MFMessageComposeViewControllerDelegate)];
		[self linkCategoryBlockProperty:@"completionBlock" withDelegateMethod:@selector(messageComposeViewController:didFinishWithResult:)];
	}
}

@end

BK_MAKE_CATEGORY_LOADABLE(MFMessageComposeViewController_BlocksKit)