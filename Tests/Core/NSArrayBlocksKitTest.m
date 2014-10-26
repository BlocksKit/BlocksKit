//
//  NSArrayBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSArray+BlocksKit.h>

@interface NSArrayBlocksKitTest : XCTestCase

@end

@implementation NSArrayBlocksKitTest {
	NSArray *_subject;
	NSArray *_integers;
	NSArray *_floats;
	NSInteger _total;
}

- (void)setUp {
	_subject = @[ @"1", @"22", @"333" ];
	_integers = @[@(1), @(2), @(3)];
	_floats = @[@(.1), @(.2), @(.3)];
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
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];

	// bk_match: is functionally identical to bk_select:, but will stop and return on the first match
	XCTAssertEqual(_total, (NSInteger)3, @"total length of \"122\" is %ld", (long)_total);
	XCTAssertEqual(found, @"22", @"matched object is %@", found);
}

- (void)testNotMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];

	// @return Returns the object if found, `nil` otherwise.
	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertNil(found, @"no matched object");
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];

	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"22" ];
	XCTAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSArray *found = [_subject bk_select:validationBlock];

	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(found.count == 0, @"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];

	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"22" ];
	XCTAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSArray *left = [_subject bk_reject:validationBlock];

	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	XCTAssertTrue(left.count == 0, @"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSArray *transformed = [_subject bk_map:transformBlock];

	XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
	NSArray *target = @[ @"1", @"2", @"3" ];
	XCTAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testReduceWithBlock {
	id(^accumlationBlock)(id, id) = ^(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject bk_reduce:@"" withBlock:accumlationBlock];
	XCTAssertTrue([concatenated isEqualToString:@"122333"], @"concatenated string is %@", concatenated);
}

- (void)testReduceWithBlockInteger {
	NSInteger(^accumlationBlockInteger)(NSInteger, id) = ^(NSInteger result, id obj) {
		return result + [obj intValue];
	};
	NSInteger result = [_integers bk_reduceInteger:0 withBlock:accumlationBlockInteger];
    XCTAssertEqual(result, (NSInteger)6, @"reduce int result is %ld", (long)result);
}

- (void)testReduceWithBlockFloat {
	CGFloat(^accumlationBlockFloat)(CGFloat, id) = ^CGFloat(CGFloat result, id obj) {
#if __LP64__
		return result + [obj doubleValue];
#else
		return result + [obj floatValue];
#endif
	};
	CGFloat result = [_floats bk_reduceFloat:.0  withBlock:accumlationBlockFloat];
#if __LP64__
    CGFloat accuracy = DBL_EPSILON;
#else
    CGFloat accuracy = FLT_EPSILON;
#endif
    XCTAssertEqualWithAccuracy(result, (CGFloat)0.6, accuracy, @"reduce float result is %f", result);
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
	XCTAssertTrue(letterExists, @"letter is not in array");
	
	BOOL letterDoesNotExist = [_subject bk_any:existsBlockFalse];
	XCTAssertFalse(letterDoesNotExist, @"letter is in array");
}

- (void)testAll {
	NSArray *names = @[ @"John", @"Joe", @"Jon", @"Jester" ];
	NSArray *names2 = @[ @"John", @"Joe", @"Jon", @"Mary" ];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithJ)(id) = ^(id obj) {
		return [obj hasPrefix:@"J"];
	};

	BOOL allNamesStartWithJ = [names bk_all:nameStartsWithJ];
	XCTAssertTrue(allNamesStartWithJ, @"all names do not start with J in array");
	
	BOOL allNamesDoNotStartWithJ = [names2 bk_all:nameStartsWithJ];
	XCTAssertFalse(allNamesDoNotStartWithJ, @"all names do start with J in array");  
}

- (void)testNone {
	NSArray *names = @[ @"John", @"Joe", @"Jon", @"Jester" ];
	NSArray *names2 = @[ @"John", @"Joe", @"Jon", @"Mary" ];
	
	// Check if array has element with prefix 1
	BOOL(^nameStartsWithM)(id) = ^(id obj) {
		return [obj hasPrefix:@"M"];
	};
	
	BOOL noNamesStartWithM = [names bk_none:nameStartsWithM];
	XCTAssertTrue(noNamesStartWithM, @"some names start with M in array");
	
	BOOL someNamesStartWithM = [names2 bk_none:nameStartsWithM];
	XCTAssertFalse(someNamesStartWithM, @"no names start with M in array");
}

- (void)testCorresponds {
	NSArray *numbers = @[ @(1), @(2), @(3) ];
	NSArray *letters = @[ @"1", @"2", @"3" ];
	BOOL doesCorrespond = [numbers bk_corresponds:letters withBlock:^(id number, id letter) {
		return [[number stringValue] isEqualToString:letter];
	}];
	XCTAssertTrue(doesCorrespond, @"1,2,3 does not correspond to \"1\",\"2\",\"3\"");
	
}

@end
