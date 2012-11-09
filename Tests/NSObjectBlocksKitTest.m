//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/4/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
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
		[sender notify: SenTestCaseWaitStatusSuccess forSelector: @selector(testPerformBlockAfterDelay)];
	};
	[self prepare];
	id block = [self performBlock:senderBlock afterDelay:0.5];
	STAssertNotNil(block,@"block is nil");
	[self waitForStatus: SenTestCaseWaitStatusSuccess timeout:1.0];
	STAssertEqualObjects(_subject,@"Hello BlocksKit",@"subject string is %@",_subject);
}

- (void)testClassPerformBlockAfterDelay {
	NSObjectBlocksKitTest *test = self;
	NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
	[self prepare];
	id blk = [NSObject performBlock:^{
		[subject appendString:@"BlocksKit"];
		[test notify: SenTestCaseWaitStatusSuccess forSelector: @selector(testClassPerformBlockAfterDelay)];
	} afterDelay:0.5];
	STAssertNotNil(blk,@"block is nil");
	[self waitForStatus: SenTestCaseWaitStatusSuccess timeout:1.0];
	STAssertEqualObjects(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
	[self prepare];
	id block = [self performBlock:^(NSObjectBlocksKitTest * sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify: SenTestCaseWaitStatusSuccess];
	} afterDelay:0.1];
	STAssertNotNil(block,@"block is nil");
	[NSObject cancelBlock:block];
	[self waitForTimeout:0.5];
	STAssertEqualObjects(_subject,@"Hello ",@"subject string is %@",_subject);
}

@end
