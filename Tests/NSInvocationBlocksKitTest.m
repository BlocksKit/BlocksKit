//
//  NSInvocationBlocksKitTest.m
//  BlocksKit
//
//  Created by WU Kai on 7/5/11.
//

#import "NSInvocationBlocksKitTest.h"


@implementation NSInvocationBlocksKitTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
    _total = 0;
}

- (void)tearDown {
    // Run after each test method
}

- (void)action {
    _total += 1;
}

- (void)testBlockInvocation {
    BKSenderBlock senderBlock = ^(id sender) {
        [(NSInvocationBlocksKitTest *)sender action];
    };
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self block:senderBlock];
    GHAssertNotNil(invocation,@"invocation is nil");
    [invocation invoke];
    GHAssertEquals(_total,1,@"total is %d",_total);
}

@end
