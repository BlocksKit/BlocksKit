//
//  MFMessageComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <MessageUI/MessageUI.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit+MessageUI.H>

@interface MFMessageComposeViewControllerBlocksKitTest : XCTestCase <MFMessageComposeViewControllerDelegate>

- (void)testCompletionBlock;

@end

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
	_subject.bk_completionBlock = ^(MFMessageComposeViewController *controller, MessageComposeResult result) {
		blockWorked = YES;
	};
	[[_subject bk_dynamicDelegateForProtocol:@protocol(MFMessageComposeViewControllerDelegate)] messageComposeViewController:_subject didFinishWithResult:MessageComposeResultSent];
	XCTAssertTrue(delegateWorked, @"Delegate method not called.");
	XCTAssertTrue(blockWorked, @"Block handler not called.");
}

@end
