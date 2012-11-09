//
//  NSOrderedSetBlocksKitTest.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/6/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "NSOrderedSetBlocksKitTest.h"

@implementation NSOrderedSetBlocksKitTest {
	id _subject;
	NSInteger _total;
	BOOL _hasClassAvailable;
}

- (void)setUp {
	Class BKOrderedSet = NSClassFromString(@"NSOrderedSet");
	if (BKOrderedSet) {
		_hasClassAvailable = YES;
		_subject = [NSOrderedSet orderedSetWithArray: @[ @"1", @"22", @"333" ]];
	} else {
		_hasClassAvailable = NO;
	}
	_total = 0;
}

- (void)tearDown {
	_subject = nil;
}

- (void)testEach {
	if (!_hasClassAvailable)
		return;

	BKSenderBlock senderBlock = ^(NSString *sender) {
		_total += [sender length];
	};
	[_subject each:senderBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testMatch {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];
	STAssertEquals(_total, (NSInteger)3, @"total length of \"122\" is %d", _total);
	STAssertEquals(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertNil(found, @"no matched object");
}

- (void)testSelect {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *found = [subject select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray: @[ @"1", @"22" ]];
	STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *found = [subject select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(found.count == 0, @"no item is selected");
}

- (void)testReject {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *left = [subject reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray: @[ @"1", @"22" ]];
	STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	if (!_hasClassAvailable)
		return;
	
	BKValidationBlock validationBlock = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *left = [subject reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(left.count == 0, @"all items are rejected");
}

- (void)testMap {
	if (!_hasClassAvailable)
		return;
	
	BKTransformBlock transformBlock = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *transformed = [subject map:transformBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray: @[ @"1", @"2", @"3" ]];
	STAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testReduceWithBlock {
	if (!_hasClassAvailable)
		return;
	
	BKAccumulationBlock accumlationBlock = ^id(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject reduce:@"" withBlock:accumlationBlock];
	STAssertTrue([concatenated isEqualToString: @"122333"], @"concatenated string is %@", concatenated);
}

- (void)testAny {
	if (!_hasClassAvailable)
		return;

	BKValidationBlock existsBlockTrue = ^BOOL(id obj) {
		return [obj hasPrefix: @"1"];
	};

	BKValidationBlock existsBlockFalse = ^BOOL(id obj) {
		return [obj hasPrefix: @"4"];
	};

	BOOL letterExists = [_subject any: existsBlockTrue];
	STAssertTrue(letterExists, @"letter is not in array");

	BOOL letterDoesNotExist = [_subject any: existsBlockFalse];
	STAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
	if (!_hasClassAvailable)
		return;

	NSOrderedSet *names = [NSOrderedSet orderedSetWithArray: @[ @"John", @"Joe", @"Jon", @"Jester" ]];
	NSOrderedSet *names2 = [NSOrderedSet orderedSetWithArray: @[ @"John", @"Joe", @"Jon", @"Mary" ]];

	// Check if array has element with prefix 1
	BKValidationBlock nameStartsWithJ = ^BOOL(id obj) {
		return [obj hasPrefix: @"J"];
	};

	BOOL allNamesStartWithJ = [names all: nameStartsWithJ];
	STAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");

	BOOL allNamesDoNotStartWithJ = [names2 all: nameStartsWithJ];
	STAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");
}

- (void)testNone {
	if (!_hasClassAvailable)
		return;

	NSOrderedSet *names = [NSOrderedSet orderedSetWithArray: @[ @"John", @"Joe", @"Jon", @"Jester" ]];
	NSOrderedSet *names2 = [NSOrderedSet orderedSetWithArray: @[ @"John", @"Joe", @"Jon", @"Mary" ]];

	// Check if array has element with prefix 1
	BKValidationBlock nameStartsWithM = ^BOOL(id obj) {
		return [obj hasPrefix: @"M"];
	};

	BOOL noNamesStartWithM = [names none: nameStartsWithM];
	STAssertTrue(noNamesStartWithM, @"some names start with M in array");

	BOOL someNamesStartWithM = [names2 none: nameStartsWithM];
	STAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
	if (!_hasClassAvailable)
		return;
	
	NSOrderedSet *numbers = [NSOrderedSet orderedSetWithArray: @[ @(1), @(2), @(3) ]];
	NSOrderedSet *letters = [NSOrderedSet orderedSetWithArray: @[ @"1", @"2", @"3" ]];
	BOOL doesCorrespond = [numbers corresponds: letters withBlock: ^(id number, id letter) {
		return [[number stringValue] isEqualToString: letter];
	}];
	STAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
}

@end
