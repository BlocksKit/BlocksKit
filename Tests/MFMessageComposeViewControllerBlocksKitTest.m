//
//  MFMessageComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests

#import "MFMessageComposeViewControllerBlocksKitTest.h"

@implementation MFMessageComposeViewControllerBlocksKitTest {
	MFMessageComposeViewController *_subject;
	BOOL delegateWorked;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUp {
	_subject = [MFMessageComposeViewController new];
}

- (void)tearDown {
	[_subject release];
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
	_subject.completionBlock = ^(MFMessageComposeViewController *controller, MessageComposeResult result){
		blockWorked = YES;
	};
	[_subject.messageComposeDelegate messageComposeViewController:_subject didFinishWithResult:MessageComposeResultSent];
	GHAssertTrue(delegateWorked, @"Delegate method not called.");
	GHAssertTrue(blockWorked, @"Block handler not called.");
}

@end
