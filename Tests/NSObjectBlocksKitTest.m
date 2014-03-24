//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSObject+BKBlockExecution.h>
#import "BKAsyncTestCase.h"

static const NSTimeInterval BKObjectTestInterval = 0.05;
static const NSTimeInterval BKObjectTestTimeout = (BKObjectTestInterval * 1.5) + 0.1;

@interface NSObjectBlocksKitTest : BKAsyncTestCase

@end


@implementation NSObjectBlocksKitTest {
	NSMutableString *_subject;	
}

- (void)setUp {
	_subject = [@"Hello " mutableCopy];
}

- (void)tearDown {
	_subject = nil;
}  

- (void)testPerformBlockAfterDelay {
	void (^senderBlock)(id) = ^(NSObjectBlocksKitTest *sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify:SenTestCaseWaitStatusSuccess forSelector:@selector(testPerformBlockAfterDelay)];
	};
	[self prepare];
	id block = [self bk_performBlock:senderBlock afterDelay:BKObjectTestInterval];
	XCTAssertNotNil(block,@"block is nil");
	[self waitForStatus:SenTestCaseWaitStatusSuccess timeout:BKObjectTestTimeout];
	XCTAssertEqualObjects(_subject,@"Hello BlocksKit",@"subject string is %@",_subject);
}

- (void)testClassPerformBlockAfterDelay {
	NSObjectBlocksKitTest *test = self;
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
	[self prepare];
	id blk = [NSObject bk_performBlock:^{
		[subject appendString:@"BlocksKit"];
		[test notify:SenTestCaseWaitStatusSuccess forSelector:@selector(testClassPerformBlockAfterDelay)];
	} afterDelay:BKObjectTestInterval];
	XCTAssertNotNil(blk,@"block is nil");
	[self waitForStatus:SenTestCaseWaitStatusSuccess timeout:BKObjectTestTimeout];
	XCTAssertEqualObjects(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
	[self prepare];
	id block = [self bk_performBlock:^(NSObjectBlocksKitTest * sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify:SenTestCaseWaitStatusSuccess];
	} afterDelay:BKObjectTestInterval];
	XCTAssertNotNil(block,@"block is nil");
	[NSObject bk_cancelBlock:block];
	[self waitForTimeout:BKObjectTestTimeout];
	XCTAssertEqualObjects(_subject,@"Hello ",@"subject string is %@",_subject);
}

@end
