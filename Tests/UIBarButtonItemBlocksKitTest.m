//
//  UIBarButtonItemBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "UIBarButtonItemBlocksKitTest.h"

@implementation UIBarButtonItemBlocksKitTest

- (BOOL)shouldRunOnMainThread {
	return YES;
}

- (void)testBlockHandler {
	__block BOOL blockCalled = NO;
	UIBarButtonItem *_subject = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
		blockCalled = YES;
	}];
	
	[_subject.target performSelector:_subject.action withObject:_subject];
	
	[_subject release];
	
	GHAssertTrue(blockCalled, @"Block handler did not get called.");
}

@end