//
//  NSArrayBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/3/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSArrayBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>

@implementation NSArrayBlocksKitTest {
	NSArray *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = @[ @"1", @"22", @"333" ];
	_total = 0;
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	void (^senderBlock)(NSString *) = ^(NSString *sender) {
		_total += [sender length];
	};
	[_subject bk_each:senderBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];

	// bk_match: is functionally identical to bk_select:, but will stop and return on the first match
	STAssertEquals(_total, (NSInteger)3, @"total length of \"122\" is %d", _total);
	STAssertEquals(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];

	// @return Returns the object if found, `nil` otherwise.
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertNil(found, @"no matched object");
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = @[ @"1", @"22" ];
	STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(found.count == 0, @"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = @[ @"1", @"22" ];
	STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(left.count == 0, @"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSArray *transformed = [_subject bk_map:transformBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSArray *target = @[ @"1", @"2", @"3" ];
	STAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testReduceWithBlock {
	id(^accumlationBlock)(id, id) = ^(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject bk_reduce:@"" withBlock:accumlationBlock];
	STAssertTrue([concatenated isEqualToString:@"122333"], @"concatenated string is %@", concatenated);
}

- (void)testAny {
	// Check if array has element with prefix 1
	BOOL(^existsBlockTrue)(id) = ^(id obj) {
		return [obj hasPrefix:@"1"];
	};
	
	BOOL(^existsBlockFalse)(id) = ^(id obj) {
		return [obj hasPrefix:@"4"];
	};
	
	BOOL letterExists = [_subject bk_any:existsBlockTrue];
	STAssertTrue(letterExists, @"letter is not in array");
	
	BOOL letterDoesNotExist = [_subject bk_any:existsBlockFalse];
	STAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
	NSArray *names = @[ @"John", @"Joe", @"Jon", @"Jester" ];
	NSArray *names2 = @[ @"John", @"Joe", @"Jon", @"Mary" ];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithJ)(id) = ^(id obj) {
		return [obj hasPrefix:@"J"];
	};

	BOOL allNamesStartWithJ = [names bk_all:nameStartsWithJ];
	STAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");
	
	BOOL allNamesDoNotStartWithJ = [names2 bk_all:nameStartsWithJ];
	STAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");  
}

- (void)testNone {
	NSArray *names = @[ @"John", @"Joe", @"Jon", @"Jester" ];
	NSArray *names2 = @[ @"John", @"Joe", @"Jon", @"Mary" ];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithM)(id) = ^(id obj) {
		return [obj hasPrefix:@"M"];
	};
	
	BOOL noNamesStartWithM = [names bk_none:nameStartsWithM];
	STAssertTrue(noNamesStartWithM, @"some names start with M in array");
	
	BOOL someNamesStartWithM = [names2 bk_none:nameStartsWithM];
	STAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
	NSArray *numbers = @[ @(1), @(2), @(3) ];
	NSArray *letters = @[ @"1", @"2", @"3" ];
	BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
		return [[number stringValue] isEqualToString:letter];
	}];
	STAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
	
}

@end
