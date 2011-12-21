//
//  NSMutableSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableSetBlocksKitTest.h"


@implementation NSMutableSetBlocksKitTest {
	NSMutableSet *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [[NSMutableSet alloc] initWithObjects:@"1",@"22",@"333",nil];
	_total = 0;
}

- (void)tearDown {
	[_subject release];
}

- (void)testSelect {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	[_subject performSelect:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"22",nil];
	GHAssertEqualObjects(_subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	[_subject performSelect:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	[_subject performReject:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"22",nil];
	GHAssertEqualObjects(_subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	[_subject performReject:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	BKTransformBlock transformBlock = ^id(id obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	[_subject performMap:transformBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"2",@"3",nil];
	GHAssertEqualObjects(_subject,target,@"transformed items are %@",_subject);
}

@end
