//
//  UIControlBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Zachary Waldowski on 12/20/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "UIControlBlocksKitTest.h"

@implementation UIControlBlocksKitTest {
	UIControl *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [UIControl new];
	_total = 0;
	
	__unsafe_unretained UIControlBlocksKitTest *weakSelf = self;
	[_subject addEventHandler:^(id sender) {
		weakSelf->_total++;
	} forControlEvents:UIControlEventTouchUpInside];
}

- (void)testHasEventHandler {
	BOOL hasHandler = [_subject hasEventHandlersForControlEvents:UIControlEventTouchUpInside];
	STAssertTrue(hasHandler, @"Control doesn't have the handler.");
}

- (void)testInvokeEventHandler {
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];
	STAssertEquals(_total, (NSInteger)1, @"Event handler did not get called.");
}

- (void)testRemoveEventHandler {
	[_subject removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];	
	STAssertEquals(_total, (NSInteger)0, @"Event handler still called.");
}

@end
