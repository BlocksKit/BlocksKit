//
//  MFMailComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "MFMailComposeViewControllerBlocksKitTest.h"
#import <BlocksKit/A2DynamicDelegate.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/BlocksKit+MessageUI.h>

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
	_subject.bk_completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *err){
		blockWorked = YES;
	};
	[[_subject bk_dynamicDelegateForProtocol:@protocol(MFMailComposeViewControllerDelegate)] mailComposeController:_subject didFinishWithResult:MFMailComposeResultSent error:nil];
	STAssertTrue(delegateWorked, @"Delegate method not called.");
	STAssertTrue(blockWorked, @"Block handler not called.");
}

@end
