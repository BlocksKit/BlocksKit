//
//  MFMessageComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+MessageUI.H>
#import "MFMessageComposeViewControllerBlocksKitTest.h"

@implementation MFMessageComposeViewControllerBlocksKitTest {
	MFMessageComposeViewController *_subject;
	BOOL delegateWorked;
}

- (void)setUp {
	_subject = [MFMessageComposeViewController new];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	delegateWorked = YES;
}

- (void)testCompletionBlock {
	if (![MFMessageComposeViewController canSendText])
		return;
	
	delegateWorked = NO;
	__block BOOL blockWorked = NO;
	_subject.messageComposeDelegate = self;
	_subject.bk_completionBlock = ^(MFMessageComposeViewController *controller, MessageComposeResult result){
		blockWorked = YES;
	};
	[[_subject bk_dynamicDelegateForProtocol:@protocol(MFMessageComposeViewControllerDelegate)] messageComposeViewController:_subject didFinishWithResult:MessageComposeResultSent];
	STAssertTrue(delegateWorked, @"Delegate method not called.");
	STAssertTrue(blockWorked, @"Block handler not called.");
}

@end
