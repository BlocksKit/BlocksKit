//
//  NSDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <Blockskit/NSDictionary+BlocksKit.h>

@interface NSDictionaryBlocksKitTest : XCTestCase

@end

@implementation NSDictionaryBlocksKitTest {
	NSDictionary *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = @{
		@"1" : @(1),
		@"2" : @(2),
		@"3" : @(3),
	};
	_total = 0;
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	void(^keyValueBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
	};

	[_subject bk_each:keyValueBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_match:validationBlock];
	XCTAssertEqual(_total, (NSInteger)2, @"2*1 = %ld", (long)_total);
	XCTAssertEqualObjects(selected, @(1), @"selected value is %@", selected);
}

- (void)testSelect {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	XCTAssertEqualObjects(selected, target, @"selected dictionary is %@", selected);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(selected.count == 0, @"none item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 3 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"3" : @(3) };
	XCTAssertEqualObjects(rejected, target, @"dictionary after rejection is %@", rejected);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(rejected.count == 0, @"all items are selected");
}

- (void)testMap {
	id(^transformBlock)(id, id) = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return @(_total);
	};
	NSDictionary *transformed = [_subject bk_map:transformBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	NSDictionary *target = @{ @"1": @(2), @"2": @(6), @"3": @(12) };
	XCTAssertEqualObjects(transformed,target,@"transformed dictionary is %@",transformed);
}

- (void)testAny {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	BOOL isSelected = [_subject bk_any:validationBlock];
	XCTAssertEqual(_total, (NSInteger)2, @"2*1 = %ld", (long)_total);
	XCTAssertEqual(isSelected, YES, @"found selected value is %i", isSelected);
}

- (void)testAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 4 ? YES : NO;
		return select;
	};
	BOOL allSelected = [_subject bk_all:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(allSelected, @"all values matched test");
}

- (void)testNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 2 ? YES : NO;
		return select;
	};
	BOOL noneSelected = [_subject bk_all:validationBlock];
	XCTAssertEqual(_total, (NSInteger)6, @"2*(1+2) = %ld", (long)_total);
	XCTAssertFalse(noneSelected, @"not all values matched test");
}

@end
