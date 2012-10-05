//
//  NSMutableArrayBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableArrayBlocksKitTest.h"

@implementation NSMutableArrayBlocksKitTest {
	NSMutableArray *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [@[ @"1", @"22", @"333" ] mutableCopy];
	_total = 0;
}

- (void)testSelect {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	[_subject performSelect:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [NSMutableArray arrayWithObjects:@"1",@"22",nil];
	STAssertEqualObjects(_subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	[_subject performSelect:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	[_subject performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [NSMutableArray arrayWithObjects:@"1",@"22",nil];
	STAssertEqualObjects(_subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	[_subject performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	BKTransformBlock transformBlock = ^id(id obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	[_subject performMap:transformBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",nil];
	STAssertEqualObjects(_subject,target,@"transformed items are %@",_subject);
}

@end
