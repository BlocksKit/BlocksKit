//
//  MFMessageComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests

#import "MFMessageComposeViewControllerBlocksKitTest.h"

@interface MFMessageComposeViewControllerBlocksKitTest() <MFMessageComposeViewControllerDelegate> {
	BOOL delegateWorked;
}

@end

@implementation MFMessageComposeViewControllerBlocksKitTest

@synthesize subject;

- (void)setUp {
	self.subject = [[[MFMessageComposeViewController alloc] init] autorelease];
}

- (void)tearDown {
	self.subject = nil;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	delegateWorked = YES;
}

- (void)testCompletionBlock {
	if (![MFMessageComposeViewController canSendText])
		return;
	
	delegateWorked = NO;
	__block BOOL blockWorked = NO;
	self.subject.messageComposeDelegate = self;
	[self.subject setCompletionBlock:^(MFMessageComposeViewController *controller, MessageComposeResult result){
		blockWorked = YES;
	}];
	[self.subject.messageComposeDelegate messageComposeViewController:self.subject didFinishWithResult:MessageComposeResultSent];
	GHAssertTrue(delegateWorked, @"Delegate method not called.");
	GHAssertTrue(blockWorked, @"Block handler not called.");
}

@end
