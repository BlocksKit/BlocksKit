//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

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
	id block = [self bk_performBlock:senderBlock afterDelay:0.5];
	STAssertNotNil(block,@"block is nil");
	[self waitForStatus:SenTestCaseWaitStatusSuccess timeout:1.0];
	STAssertEqualObjects(_subject,@"Hello BlocksKit",@"subject string is %@",_subject);
}

- (void)testClassPerformBlockAfterDelay {
	NSObjectBlocksKitTest *test = self;
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
	[self prepare];
	id blk = [NSObject bk_performBlock:^{
		[subject appendString:@"BlocksKit"];
		[test notify:SenTestCaseWaitStatusSuccess forSelector:@selector(testClassPerformBlockAfterDelay)];
	} afterDelay:0.5];
	STAssertNotNil(blk,@"block is nil");
	[self waitForStatus:SenTestCaseWaitStatusSuccess timeout:1.0];
	STAssertEqualObjects(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
	[self prepare];
	id block = [self bk_performBlock:^(NSObjectBlocksKitTest * sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify:SenTestCaseWaitStatusSuccess];
	} afterDelay:0.1];
	STAssertNotNil(block,@"block is nil");
	[NSObject bk_cancelBlock:block];
	[self waitForTimeout:0.5];
	STAssertEqualObjects(_subject,@"Hello ",@"subject string is %@",_subject);
}

@end
