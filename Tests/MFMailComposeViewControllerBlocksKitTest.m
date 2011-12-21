//
//  MFMailComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "MFMailComposeViewControllerBlocksKitTest.h"

@implementation MFMailComposeViewControllerBlocksKitTest {
	MFMailComposeViewController *_subject;
	BOOL delegateWorked;
}

- (void)setUp {
	_subject = [MFMailComposeViewController new];
}

- (void)tearDown {
	[_subject release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	delegateWorked = YES;
}

- (void)testCompletionBlock {
	delegateWorked = NO;
	__block BOOL blockWorked = NO;
	_subject.mailComposeDelegate = self;
	_subject.completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *err){
		blockWorked = YES;
	};
	[_subject.mailComposeDelegate mailComposeController:_subject didFinishWithResult:MFMailComposeResultSent error:nil];
	GHAssertTrue(delegateWorked, @"Delegate method not called.");
	GHAssertTrue(blockWorked, @"Block handler not called.");
}

@end
