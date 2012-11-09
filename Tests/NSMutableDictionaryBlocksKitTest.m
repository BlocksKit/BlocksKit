//
//  NSMutableDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/7/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSMutableDictionaryBlocksKitTest.h"

@implementation NSMutableDictionaryBlocksKitTest {
	NSMutableDictionary *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [@{
		@"1" : @(1),
		@"2" : @(2),
		@"3" : @(3)
	} mutableCopy];
	_total = 0;
}

- (void)testSelect {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	[_subject performSelect:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	STAssertEqualObjects(_subject,target,@"selected dictionary is %@",_subject);
}

- (void)testSelectedNone {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	[_subject performSelect:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] > 2 ? YES : NO;
		return reject;
	};
	[_subject performReject:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	STAssertEqualObjects(_subject,target,@"dictionary after reject is %@",_subject);
}

- (void)testRejectedAll {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	[_subject performReject:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	BKKeyValueTransformBlock transformBlock = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return @(_total);
	};
	[_subject performMap:transformBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{
		@"1" : @(2),
		@"2" : @(6),
		@"3" : @(12)
	};
	STAssertEqualObjects(_subject,target,@"transformed dictionary is %@",_subject);
}

@end
