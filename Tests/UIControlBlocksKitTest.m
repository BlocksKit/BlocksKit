//
//  UIControlBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface UIControlBlocksKitTest : XCTestCase

@end

@implementation UIControlBlocksKitTest {
	UIControl *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [UIControl new];
	_total = 0;
	
	__unsafe_unretained UIControlBlocksKitTest *weakSelf = self;
	[_subject bk_addEventHandler:^(id sender) {
		weakSelf->_total++;
	} forControlEvents:UIControlEventTouchUpInside];
}

- (void)testHasEventHandler {
	BOOL hasHandler = [_subject bk_hasEventHandlersForControlEvents:UIControlEventTouchUpInside];
	XCTAssertTrue(hasHandler, @"Control doesn't have the handler.");
}

- (void)testInvokeEventHandler {
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];
	XCTAssertEqual(_total, (NSInteger)1, @"Event handler did not get called.");
}

- (void)testRemoveEventHandler {
	[_subject bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
	[_subject sendActionsForControlEvents:UIControlEventTouchUpInside];	
	XCTAssertEqual(_total, (NSInteger)0, @"Event handler still called.");
}

@end
