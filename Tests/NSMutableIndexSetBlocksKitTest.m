//
//  NSMutableIndexSetBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSMutableIndexSet+BlocksKit.h>

@interface NSMutableIndexSetBlocksKitTest : XCTestCase

@end

@implementation NSMutableIndexSetBlocksKitTest {
	NSMutableIndexSet *_subject;
	NSMutableArray *_target;
}

- (void)setUp {
	_target = [@[@"0", @"0", @"0", @"0"] mutableCopy];
	_subject = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
}

- (void)testSelect {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger index) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = index < 3 ? YES : NO; //1,2
		return match;
	};
	[_subject bk_performSelect:indexValidationBlock];
	XCTAssertEqualObjects(order,@"123",@"the index loop order is %@",order);
	NSMutableIndexSet *target = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)];
	XCTAssertEqualObjects(_subject,target,@"the selected index set is %@",_subject);
}

- (void)testSelectedNone {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger index) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = index == 0 ? YES : NO;
		return match;
	};
	[_subject bk_performSelect:indexValidationBlock];
	XCTAssertEqualObjects(order,@"123",@"the index loop order is %@",order);
	XCTAssertEqual(_subject.count,(NSUInteger)0,@"no index found");
}

- (void)testReject {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger index) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = [_target[index] isEqual:@"0"] ? YES : NO;
		return match;
	};
	[_subject bk_performReject:indexValidationBlock];
	XCTAssertEqualObjects(order,@"123",@"the index loop order is %@",order);
	XCTAssertEqual(_subject.count,(NSUInteger)0,@"all indexes are rejected");
}

- (void)testRejectedNone {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger index) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = [_target[index] isEqual:@"0"] ? NO : YES;
		return match;
	};
	[_subject bk_performReject:indexValidationBlock];
	XCTAssertEqualObjects(order,@"123",@"the index loop order is %@",order);
	NSMutableIndexSet *target = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1,3)];
	XCTAssertEqualObjects(_subject,target,@"the rejected index set is %@",_subject);
}

@end
