//
//  NSIndexSetBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSIndexSet+BlocksKit.h>

@interface NSIndexSetBlocksKitTest : XCTestCase

@end

@implementation NSIndexSetBlocksKitTest {
	NSIndexSet *_subject;
	NSMutableArray  *_target;
}

- (void)setUp {
	_target = [@[@"0", @"0", @"0", @"0"] mutableCopy];
	_subject = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
}

- (void)testEach {
	NSMutableString *order = [NSMutableString string];
	void(^indexBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		_target[index] = [NSString stringWithFormat:@"%lu", (unsigned long)index];
	};
	[_subject bk_each:indexBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	NSArray *target = @[ @"0", @"1", @"2", @"3" ];
	XCTAssertEqualObjects(_target, target, @"the target array becomes %@", _target);
}

- (void)testMatch {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = NO;
		if (index%2 == 0 ) {
			_target[index] = [NSString stringWithFormat:@"%lu", (unsigned long)index];
			match = YES;
		}
		return match;
	};
	NSUInteger found = [_subject bk_match:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"12"], @"the index loop order is %@", order);
	XCTAssertEqualObjects(_target[found], @"2", @"the target array becomes %@", _target);
}

- (void)testNotMatch {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = index > 4 ? YES : NO;
		return match;
	};
	NSUInteger found = [_subject bk_match:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	XCTAssertEqual((NSUInteger)found, (NSUInteger)NSNotFound, @"no items are found");
}

- (void)testSelect {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = index < 3 ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_select:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	NSIndexSet *target = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)];
	XCTAssertEqualObjects(found, target, @"the selected index set is %@", found);
}

- (void)testSelectedNone {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = index == 0 ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_select:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	XCTAssertNil(found,@"no index found");
}

- (void)testReject {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = [_target[index] isEqual:@"0"] ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject bk_reject:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	XCTAssertNil(found,@"all indexes are rejected");
}

- (void)testRejectedNone {
	NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = [_target[index] isEqual:@"0"] ? NO : YES;
		return match;
	};
	NSIndexSet *found = [_subject bk_reject:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"123"], @"the index loop order is %@", order);
	XCTAssertEqualObjects(found, _subject, @"all indexes that are not rejected %@", found);
}

- (void)testAny {
	__block NSMutableString *order = [NSMutableString string];
	BOOL(^indexValidationBlock)(NSUInteger) = ^(NSUInteger index) {
		[order appendFormat:@"%lu", (unsigned long)index];
		BOOL match = NO;
		if (index%2 == 0 ) {
			_target[index] = [NSString stringWithFormat:@"%lu", (unsigned long)index];
			match = YES;
		}
		return match;
	};
	BOOL didFind = [_subject bk_any:indexValidationBlock];
	XCTAssertTrue([order isEqualToString:@"12"], @"the index loop order is %@", order);
	XCTAssertTrue(didFind, @"result found in target array");
}

@end
