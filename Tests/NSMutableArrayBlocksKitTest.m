//
//  NSMutableArrayBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableArrayBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@implementation NSMutableArrayBlocksKitTest {
	NSMutableArray *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [@[ @"1", @"22", @"333" ] mutableCopy];
	_total = 0;
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	[_subject bk_performSelect:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [@[ @"1", @"22" ] mutableCopy];
	STAssertEqualObjects(_subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	[_subject bk_performSelect:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	[_subject bk_performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [@[ @"1", @"22" ] mutableCopy];
	STAssertEqualObjects(_subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	[_subject bk_performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	[_subject bk_performMap:transformBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableArray *target = [@[ @"1", @"2", @"3" ] mutableCopy];
	STAssertEqualObjects(_subject,target,@"transformed items are %@",_subject);
}

@end
