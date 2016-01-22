//
// Created by Agens AS for BlocksKit on 21.10.14.
//

@import XCTest;
@import BlocksKit;

@interface NSMapTableBlocksKitTest : XCTestCase

@end

@implementation NSMapTableBlocksKitTest {
    NSMapTable *_subject;
    NSInteger _total;
}

- (void)setUp {

    _subject = [NSMapTable strongToStrongObjectsMapTable];
    [_subject setObject:@1 forKey:@"1"];
    [_subject setObject:@2 forKey:@"2"];
    [_subject setObject:@3 forKey:@"3"];

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

	NSMapTable *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@1 forKey:@"1"];
	[target setObject:@2 forKey:@"2"];

	XCTAssertEqualObjects(selected, target, @"selected dictionary is %@", selected);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	NSMapTable *selected = [_subject bk_select:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(selected.count == 0, @"none item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 3 ? YES : NO;
		return reject;
	};

	NSMapTable *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@3 forKey:@"3"];

	XCTAssertEqualObjects(rejected, target, @"dictionary after rejection is %@", rejected);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};

	NSMapTable *rejected = [_subject bk_reject:validationBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);
	XCTAssertTrue(rejected.count == 0, @"all items are selected");
}

- (void)testMap {
	id(^transformBlock)(id, id) = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return @(_total);
	};

	NSMapTable *transformed = [_subject bk_map:transformBlock];
	XCTAssertEqual(_total, (NSInteger)12, @"2*(1+2+3) = %ld", (long)_total);

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@2 forKey:@"1"];
	[target setObject:@6 forKey:@"2"];
	[target setObject:@12 forKey:@"3"];

	XCTAssertEqualObjects(transformed,target,@"transformed maptable is %@",transformed);
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

- (void)testPerformSelect {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL select = [value integerValue] < 3 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@1 forKey:@"1"];
	[target setObject:@2 forKey:@"2"];
	XCTAssertEqualObjects(_subject, target, @"selected maptable is %@", _subject);
}

- (void)testPerformSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL select = [value integerValue] > 4 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];

	XCTAssertEqual(_subject.count, (NSUInteger)0, @"no item is selected");
}

- (void)testPerformReject {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL reject = [value integerValue] > 2 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@1 forKey:@"1"];
	[target setObject:@2 forKey:@"2"];
	XCTAssertEqualObjects(_subject,target,@"maptable after reject is %@",_subject);
}

- (void)testPerformRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL reject = [value integerValue] < 4 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];

	XCTAssertEqual(_subject.count, (NSUInteger)0, @"all items are rejected");
}

- (void)testPerformMap {
	id(^transformBlock)(id, id) = ^(id key, NSNumber *value) {
		return @([value integerValue] * 2);
	};
	[_subject bk_performMap:transformBlock];

	NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
	[target setObject:@2 forKey:@"1"];
	[target setObject:@4 forKey:@"2"];
	[target setObject:@6 forKey:@"3"];
	XCTAssertEqualObjects(_subject, target, @"transformed maptable is %@", _subject);
}

@end
