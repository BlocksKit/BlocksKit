//
//  MFMessageComposeViewControllerBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

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
	_subject.completionBlock = ^(MFMessageComposeViewController *controller, MessageComposeResult result){
		blockWorked = YES;
	};
	[[_subject dynamicDelegateForProtocol:@protocol(MFMessageComposeViewControllerDelegate)] messageComposeViewController:_subject didFinishWithResult:MessageComposeResultSent];
	STAssertTrue(delegateWorked, @"Delegate method not called.");
	STAssertTrue(blockWorked, @"Block handler not called.");
}

@end
