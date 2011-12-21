//
//  NSObjectBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSObjectBlocksKitTest.h"

@implementation NSObjectBlocksKitTest {
	NSMutableString *_subject;	
}

- (void)setUp {
	_subject = [[NSMutableString alloc] initWithString:@"Hello "];
}

- (void)tearDown {
	[_subject release];
}  

- (void)testPerformBlockAfterDelay {
	BKSenderBlock senderBlock = ^(NSObjectBlocksKitTest *sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify:kGHUnitWaitStatusSuccess forSelector:@selector(testPerformBlockAfterDelay)];
	};
	[self prepare];
	id block = [self performBlock:senderBlock afterDelay:0.5];
	GHAssertNotNil(block,@"block is nil");
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
	GHAssertEqualStrings(_subject,@"Hello BlocksKit",@"subject string is %@",_subject);
}

- (void)testClassPerformBlockAfterDelay {
	__block NSObjectBlocksKitTest *test = self;
	__block NSMutableString *subject = [NSMutableString stringWithString:@"Hello "];
	[self prepare];
	id blk = [NSObject performBlock:^{
		[subject appendString:@"BlocksKit"];
		[test notify:kGHUnitWaitStatusSuccess forSelector:@selector(testClassPerformBlockAfterDelay)];
	} afterDelay:0.5];
	GHAssertNotNil(blk,@"block is nil");
	[self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.0];
	GHAssertEqualStrings(subject,@"Hello BlocksKit",@"subject string is %@",subject);
}

- (void)testCancel {
	[self prepare];
	id block = [self performBlock:^(NSObjectBlocksKitTest * sender) {
		[_subject appendString:@"BlocksKit"];
		[sender notify:kGHUnitWaitStatusSuccess forSelector:@selector(testCancel)];
	} afterDelay:0.1];
	GHAssertNotNil(block,@"block is nil");
	[NSObject cancelBlock:block];
	[self waitForTimeout:0.5];
	GHAssertEqualStrings(_subject,@"Hello ",@"subject string is %@",_subject);
}

@end
