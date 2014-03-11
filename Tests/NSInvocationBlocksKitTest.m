//
//  NSInvocationBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSInvocation+BlocksKit.h>

@interface NSInvocationBlocksKitTest : XCTestCase

- (void)testBlockInvocation;

@end

@implementation NSInvocationBlocksKitTest {
	NSInteger _total;	
}

- (void)setUp {
	_total = 0;
}

- (void)action {
	_total += 1;
}

- (void)testBlockInvocation {
	void (^senderBlock)(NSInvocationBlocksKitTest *) = ^(NSInvocationBlocksKitTest *sender) {
		[sender action];
	};
	NSInvocation *invocation = [NSInvocation bk_invocationWithTarget:self block:senderBlock];
	XCTAssertNotNil(invocation, @"invocation is nil");
	[invocation invoke];
	XCTAssertEqual(_total, (NSInteger)1, @"total is %ld", (long)_total);
}

@end
