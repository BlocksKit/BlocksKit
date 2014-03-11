//
//  MFMailComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <MessageUI/MessageUI.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit+MessageUI.h>

@interface MFMailComposeViewControllerBlocksKitTest : XCTestCase <MFMailComposeViewControllerDelegate>

@end

@implementation MFMailComposeViewControllerBlocksKitTest {
	MFMailComposeViewController *_subject;
	BOOL delegateWorked;
}

- (void)setUp {
	_subject = [MFMailComposeViewController new];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	delegateWorked = YES;
}

- (void)testCompletionBlock {
	delegateWorked = NO;
	__block BOOL blockWorked = NO;
	_subject.mailComposeDelegate = self;
	_subject.bk_completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *err) {
		blockWorked = YES;
	};
	[[_subject bk_dynamicDelegateForProtocol:@protocol(MFMailComposeViewControllerDelegate)] mailComposeController:_subject didFinishWithResult:MFMailComposeResultSent error:nil];
	XCTAssertTrue(delegateWorked, @"Delegate method not called.");
	XCTAssertTrue(blockWorked, @"Block handler not called.");
}

@end
