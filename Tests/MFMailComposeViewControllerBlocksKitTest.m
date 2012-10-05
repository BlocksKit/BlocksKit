//
//  MFMailComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "MFMailComposeViewControllerBlocksKitTest.h"

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
	_subject.completionBlock = ^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *err){
		blockWorked = YES;
	};
	[[_subject dynamicDelegateForProtocol:@protocol(MFMailComposeViewControllerDelegate)] mailComposeController:_subject didFinishWithResult:MFMailComposeResultSent error:nil];
	STAssertTrue(delegateWorked, @"Delegate method not called.");
	STAssertTrue(blockWorked, @"Block handler not called.");
}

@end
