//
//  MFMailComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "MFMailComposeViewControllerBlocksKitTest.h"

@interface MFMailComposeViewControllerBlocksKitTest() <MFMailComposeViewControllerDelegate> {
	BOOL delegateWorked;
}

@end

@implementation MFMailComposeViewControllerBlocksKitTest

@synthesize subject;

- (void)setUp {
	self.subject = [[[MFMailComposeViewController alloc] init] autorelease];
}

- (void)tearDownClass {
	self.subject = nil;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	delegateWorked = YES;
}

- (void)testCompletionBlock {
	delegateWorked = NO;
	__block BOOL blockWorked = NO;
	self.subject.mailComposeDelegate = self;
	self.subject.completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *err){
		blockWorked = YES;
	};
	[self.subject.mailComposeDelegate mailComposeController:self.subject didFinishWithResult:MFMailComposeResultSent error:nil];
	GHAssertTrue(delegateWorked, @"Delegate method not called.");
	GHAssertTrue(blockWorked, @"Block handler not called.");
}

@end
