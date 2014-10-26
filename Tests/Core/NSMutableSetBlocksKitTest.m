//
//  NSMutableSetBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSMutableSet+BlocksKit.h>

@interface NSMutableSetBlocksKitTest : XCTestCase

@end

@implementation NSMutableSetBlocksKitTest {
	NSMutableSet *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [NSMutableSet setWithArray:@[ @"1", @"22", @"333"]];;
	_total = 0;
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	[_subject bk_performSelect:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableSet *target = [NSMutableSet setWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(_subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	[_subject bk_performSelect:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertEqual(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	[_subject bk_performReject:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableSet *target = [NSMutableSet setWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(_subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	[_subject bk_performReject:validationBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertEqual(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	[_subject bk_performMap:transformBlock];
	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableSet *target = [NSMutableSet setWithArray:@[ @"1", @"2", @"3" ]];
	XCTAssertEqualObjects(_subject,target,@"transformed items are %@",_subject);
}

@end
