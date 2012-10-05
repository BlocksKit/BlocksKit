//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectBlocksKitTest.h"

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
	BKSenderBlock senderBlock = ^(NSObjectBlocksKitTest *sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify: SenAsyncTestCaseStatusSucceeded];
	};
	id block = [self performBlock:senderBlock afterDelay:0.5];
	STAssertNotNil(block,@"block is nil");
	[self waitForStatus: SenAsyncTestCaseStatusSucceeded timeout:1.0];
	STAssertEqualObjects(_subject,@"Hello BlocksKit",@"subject string is %@",_subject);
}

- (void)testClassPerformBlockAfterDelay {
	NSObjectBlocksKitTest *test = self;
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
	id blk = [NSObject performBlock:^{
		[subject appendString:@"BlocksKit"];
		[test notify: SenAsyncTestCaseStatusSucceeded];
	} afterDelay:0.5];
	STAssertNotNil(blk,@"block is nil");
	[self waitForStatus: SenAsyncTestCaseStatusSucceeded timeout:1.0];
	STAssertEqualObjects(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
	id block = [self performBlock:^(NSObjectBlocksKitTest * sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify: SenAsyncTestCaseStatusSucceeded];
	} afterDelay:0.1];
	STAssertNotNil(block,@"block is nil");
	[NSObject cancelBlock:block];
	[self waitForTimeout:0.5];
	STAssertEqualObjects(_subject,@"Hello ",@"subject string is %@",_subject);
}

@end
