//
//  NSOrderedSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSOrderedSetBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>

@implementation NSOrderedSetBlocksKitTest {
	id _subject;
	NSInteger _total;
	BOOL _hasClassAvailable;
}

- (void)setUp {
	Class BKOrderedSet = NSClassFromString(@"NSOrderedSet");
	if (BKOrderedSet) {
		_hasClassAvailable = YES;
		_subject = [NSOrderedSet orderedSetWithArray:@[ @"1", @"22", @"333" ]];
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

	void(^senderBlock)(id) = ^(NSString *sender) {
		_total += [sender length];
	};
	[(NSOrderedSet *)_subject bk_each:senderBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testMatch {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [(NSOrderedSet *)_subject bk_match:validationBlock];
	STAssertEquals(_total, (NSInteger)3, @"total length of \"122\" is %d", _total);
	STAssertEquals(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [(NSOrderedSet *)_subject bk_match:validationBlock];
	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertNil(found, @"no matched object");
}

- (void)testSelect {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *found = [subject bk_select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *found = [subject bk_select:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(found.count == 0, @"no item is selected");
}

- (void)testReject {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *left = [subject bk_reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	if (!_hasClassAvailable)
		return;
	
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *left = [subject bk_reject:validationBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	STAssertTrue(left.count == 0, @"all items are rejected");
}

- (void)testMap {
	if (!_hasClassAvailable)
		return;
	
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSOrderedSet *subject = _subject;
	NSOrderedSet *transformed = [subject bk_map:transformBlock];

	STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
	NSOrderedSet *target = [NSOrderedSet orderedSetWithArray:@[ @"1", @"2", @"3" ]];
	STAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testReduceWithBlock {
	if (!_hasClassAvailable)
		return;
	
	id(^accumlationBlock)(id, id) = ^(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject bk_reduce:@"" withBlock:accumlationBlock];
	STAssertTrue([concatenated isEqualToString:@"122333"], @"concatenated string is %@", concatenated);
}

- (void)testAny {
	if (!_hasClassAvailable)
		return;

	BOOL(^existsBlockTrue)(id) = ^BOOL(id obj) {
		return [obj hasPrefix:@"1"];
	};

	BOOL(^existsBlockFalse)(id) = ^BOOL(id obj) {
		return [obj hasPrefix:@"4"];
	};

	BOOL letterExists = [(NSOrderedSet *)_subject bk_any:existsBlockTrue];
	STAssertTrue(letterExists, @"letter is not in array");

	BOOL letterDoesNotExist = [(NSOrderedSet *)_subject bk_any:existsBlockFalse];
	STAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
	if (!_hasClassAvailable)
		return;

	NSOrderedSet *names = [NSOrderedSet orderedSetWithArray:@[ @"John", @"Joe", @"Jon", @"Jester" ]];
	NSOrderedSet *names2 = [NSOrderedSet orderedSetWithArray:@[ @"John", @"Joe", @"Jon", @"Mary" ]];

	// Check if array has element with prefix 1
	BOOL(^nameStartsWithJ)(id) = ^BOOL(id obj) {
		return [obj hasPrefix:@"J"];
	};

	BOOL allNamesStartWithJ = [names bk_all:nameStartsWithJ];
	STAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");

	BOOL allNamesDoNotStartWithJ = [names2 bk_all:nameStartsWithJ];
	STAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");
}

- (void)testNone {
	if (!_hasClassAvailable)
		return;

	NSOrderedSet *names = [NSOrderedSet orderedSetWithArray:@[ @"John", @"Joe", @"Jon", @"Jester" ]];
	NSOrderedSet *names2 = [NSOrderedSet orderedSetWithArray:@[ @"John", @"Joe", @"Jon", @"Mary" ]];

	// Check if array has element with prefix 1
	BOOL(^nameStartsWithM)(id) = ^BOOL(id obj) {
		return [obj hasPrefix:@"M"];
	};

	BOOL noNamesStartWithM = [names bk_none:nameStartsWithM];
	STAssertTrue(noNamesStartWithM, @"some names start with M in array");

	BOOL someNamesStartWithM = [names2 bk_none:nameStartsWithM];
	STAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
	if (!_hasClassAvailable)
		return;
	
	NSOrderedSet *numbers = [NSOrderedSet orderedSetWithArray:@[ @(1), @(2), @(3) ]];
	NSOrderedSet *letters = [NSOrderedSet orderedSetWithArray:@[ @"1", @"2", @"3" ]];
	BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
		return [[number stringValue] isEqualToString:letter];
	}];
	STAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
}

@end
