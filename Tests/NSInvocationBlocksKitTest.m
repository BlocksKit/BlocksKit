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
	BKSenderBlock senderBlock = ^(NSInvocationBlocksKitTest * sender) {
		[sender action];
	};
	NSInvocation *invocation = [NSInvocation invocationWithTarget:self block:senderBlock];
	GHAssertNotNil(invocation,@"invocation is nil");
	[invocation invoke];
	GHAssertEquals(_total,1,@"total is %d",_total);
}

@end
