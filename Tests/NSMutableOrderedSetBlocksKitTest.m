//
//  NSMutableOrderedSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSMutableOrderedSet+BlocksKit.h>

@interface NSMutableOrderedSetBlocksKitTest : XCTestCase

@end

@implementation NSMutableOrderedSetBlocksKitTest {
	id _subject;
	NSInteger _total;
	BOOL _hasClassAvailable;
}

- (void)setUp {
	Class BKOrderedSet = NSClassFromString(@"NSMutableOrderedSet");
	if (BKOrderedSet) {
		_hasClassAvailable = YES;
		_subject = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22", @"333" ]];
	} else {
		_hasClassAvailable = NO;
	}
	_total = 0;
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performSelect:validationBlock];

	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performSelect:validationBlock];

	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertEqual(subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performReject:validationBlock];

	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	XCTAssertEqualObjects(subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performReject:validationBlock];

	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	XCTAssertEqual(subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performMap:transformBlock];

	XCTAssertEqual(_total,(NSInteger)6,@"total length of \"122333\" is %ld", (long)_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22", @"333" ]];
	XCTAssertEqualObjects(subject,target,@"transformed items are %@",_subject);
}

@end
