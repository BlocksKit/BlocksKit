//
//  UIControlBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIControlBlocksKitTest.h"

@implementation UIControlBlocksKitTest {
	UIControl *_subject;
	NSInteger _total;
}

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)setUpClass {
	_subject = [UIControl new];
	_total = 0;
}

- (void)tearDownClass {
	[_subject release];
}

- (void)testAddEventHandler {
	[_subject addEventHandler:^(id sender) {
		_total++;
	} forControlEvents:UIControlEventTouchUpInside];
	
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];
	
	GHAssertEquals(_total, 1, @"Event handler did not get called.");
}

- (void)testHasEventHandler {
	BOOL hasHandler = [_subject hasEventHandlersForControlEvents:UIControlEventTouchUpInside];
	GHAssertTrue(hasHandler, @"Control doesn't have the handler.");
}

- (void)testRemoveEventHandler {
	[_subject removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];	
	GHAssertEquals(_total, 1, @"Event handler still called.");
}

@end
