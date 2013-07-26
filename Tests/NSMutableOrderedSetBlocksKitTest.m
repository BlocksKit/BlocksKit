//
//  NSMutableOrderedSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableOrderedSetBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>

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

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performSelect:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performReject:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertEquals(subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSMutableOrderedSet *subject = _subject;
	[subject bk_performMap:transformBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSMutableOrderedSet *target = [NSMutableOrderedSet orderedSetWithArray:@[ @"1", @"22", @"333" ]];
	STAssertEqualObjects(subject,target,@"transformed items are %@",_subject);
}

@end
