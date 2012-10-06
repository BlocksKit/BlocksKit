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

- (void)setUpClass {
	_subject = [UIControl new];
	_total = 0;
}

- (void)testAddEventHandler {
	__unsafe_unretained UIControlBlocksKitTest *weakSelf = self;
	[_subject addEventHandler:^(id sender) {
		weakSelf->_total++;
	} forControlEvents:UIControlEventTouchUpInside];
	
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];
	
	STAssertEquals(_total, (NSInteger)1, @"Event handler did not get called.");
}

- (void)testHasEventHandler {
	BOOL hasHandler = [_subject hasEventHandlersForControlEvents:UIControlEventTouchUpInside];
	STAssertTrue(hasHandler, @"Control doesn't have the handler.");
}

- (void)testRemoveEventHandler {
	[_subject removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];	
	STAssertEquals(_total, (NSInteger)1, @"Event handler still called.");
}

@end
