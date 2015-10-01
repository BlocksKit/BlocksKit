//
//  UIControlBlocksKitTest.m
//  BlocksKit Unit Tests
//

@import XCTest;
@import BlocksKit.Dynamic.UIKit;

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

- (void)testRemoveEventHandler {
	[_subject bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    
    BOOL hasHandler = [_subject bk_hasEventHandlersForControlEvents:UIControlEventTouchUpInside];
    XCTAssertFalse(hasHandler, @"Control still has the handler.");
}

@end
