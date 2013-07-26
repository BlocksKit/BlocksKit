//
//  NSDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/3/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSDictionaryBlocksKitTest.h"

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
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
}

- (void)testMatch {
    BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_match:validationBlock];
	STAssertEquals(_total, (NSInteger)2, @"2*1 = %d", _total);
	STAssertEqualObjects(selected, @(1), @"selected value is %@", selected);
}

- (void)testSelect {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	STAssertEqualObjects(selected, target, @"selected dictionary is %@", selected);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject bk_select:validationBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	STAssertTrue(selected.count == 0, @"none item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 3 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	NSDictionary *target = @{ @"3" : @(3) };
	STAssertEqualObjects(rejected, target, @"dictionary after rejection is %@", rejected);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject bk_reject:validationBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	STAssertTrue(rejected.count == 0, @"all items are selected");
}

- (void)testMap {
	id(^transformBlock)(id, id) = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return @(_total);
	};
	NSDictionary *transformed = [_subject bk_map:transformBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	NSDictionary *target = @{ @"1": @(2), @"2": @(6), @"3": @(12) };
	STAssertEqualObjects(transformed,target,@"transformed dictionary is %@",transformed);
}

- (void)testAny {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	BOOL isSelected = [_subject bk_any:validationBlock];
	STAssertEquals(_total, (NSInteger)2, @"2*1 = %d", _total);
	STAssertEquals(isSelected, YES, @"found selected value is %i", isSelected);
}

- (void)testAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 4 ? YES : NO;
		return select;
	};
	BOOL allSelected = [_subject bk_all:validationBlock];
	STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
	STAssertTrue(allSelected, @"all values matched test");
}

- (void)testNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 2 ? YES : NO;
		return select;
	};
	BOOL noneSelected = [_subject bk_all:validationBlock];
	STAssertEquals(_total, (NSInteger)6, @"2*(1+2) = %d", _total);
	STAssertFalse(noneSelected, @"not all values matched test");
}

@end
