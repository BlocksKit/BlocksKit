//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSObject+BKBlockExecution.h>
#import "XCTestCase+BKAsyncTestCase.h"

static const NSTimeInterval BKObjectTestInterval = 0.025;
static const NSTimeInterval BKObjectTestTimeout = 1.0;

@interface NSObjectBlocksKitTest : XCTestCase

@end

@implementation NSObjectBlocksKitTest

- (void)testPerformBlockAfterDelay {
	NSMutableString *subject = [@"Hello" mutableCopy];
	void (^senderBlock)(id) = ^(NSObjectBlocksKitTest *sender) {
		[subject appendString:@" BlocksKit"];
		[sender bk_finishRunningAsyncTest];
	};
	
	[self bk_performAsyncTestWithTimeout:BKObjectTestTimeout block:^{
		id block = [self bk_performBlock:senderBlock afterDelay:BKObjectTestInterval];
		XCTAssertNotNil(block,@"block is nil");
	}];
	
	XCTAssertEqualObjects(subject, @"Hello BlocksKit", @"subject string is %@", subject);
}

- (void)testClassPerformBlockAfterDelay {
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello"];
	void (^senderBlock)(void) = ^{
		[subject appendString:@" BlocksKit"];
		[self bk_finishRunningAsyncTest];
	};
	
	[self bk_performAsyncTestWithTimeout:BKObjectTestTimeout block:^{
		id block = [NSObject bk_performBlock:senderBlock afterDelay:BKObjectTestInterval];
		XCTAssertNotNil(block,@"block is nil");
	}];
	
	XCTAssertEqualObjects(subject, @"Hello BlocksKit", @"subject string is %@", subject);
}

- (void)testCancel {
	NSMutableString *subject = [@"Hello" mutableCopy];
	void (^senderBlock)(id) = ^(NSObjectBlocksKitTest *sender){
		[subject appendString:@" BlocksKit"];
		[self bk_finishRunningAsyncTest];
	};
	
	[self bk_performAsyncTestWithTimeout:BKObjectTestTimeout block:^{
		id block = [self bk_performBlock:senderBlock afterDelay:BKObjectTestInterval];
		if (!block) {
			[self bk_finishRunningAsyncTest];
			XCTFail(@"block is nil");
		}
		[NSObject bk_cancelBlock:block];
		[NSObject bk_performBlock:^{
			[self bk_finishRunningAsyncTest];
		} afterDelay:BKObjectTestInterval];
	}];
	
	XCTAssertEqualObjects(subject, @"Hello", @"subject string is %@", subject);
}

@end
