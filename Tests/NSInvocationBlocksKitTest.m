//
//  NSInvocationBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSInvocationBlocksKitTest.h"

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
	STAssertNotNil(invocation, @"invocation is nil");
	[invocation invoke];
	STAssertEquals(_total, (NSInteger)1, @"total is %d", _total);
}

@end
