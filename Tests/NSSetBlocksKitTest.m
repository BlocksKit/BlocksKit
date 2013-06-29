//
//  NSSetBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Created by Kai Wu on 7/4/11.
//  Copyright (c) 2011-2012 Pandamonia LLC. All rights reserved.
//

#import "NSSetBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>

@implementation NSSetBlocksKitTest {
	NSSet *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [NSSet setWithArray:@[ @"1", @"22", @"333" ]];
	_total = 0;
}

- (void)testEach {
	void(^senderBlock)(id) = ^(NSString *sender) {
		_total += [sender length];
	};
	[_subject bk_each:senderBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
}

- (void)testMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];
	STAssertEquals(_total,(NSInteger)3,@"total length of \"122\" is %d",_total);
	STAssertEquals(found,@"22",@"matched object is %@",found);
}

- (void)testNotMatch {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject bk_match:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertNil(found,@"no matched object");
}

- (void)testSelect {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject bk_select:validationBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(found,target,@"selected items are %@",found);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject bk_select:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertTrue(found.count == 0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject bk_reject:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"22" ]];
	STAssertEqualObjects(left,target,@"not rejected items are %@",left);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject bk_reject:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertTrue(left.count == 0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSSet *transformed = [_subject bk_map:transformBlock];

	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithArray:@[ @"1", @"2", @"3" ]];
	STAssertEqualObjects(transformed,target,@"transformed items are %@",transformed);
}

- (void)testReduceWithBlock {
	id(^accumlationBlock)(id, id) = ^(NSString *sum, NSString *obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject bk_reduce:@"" withBlock:accumlationBlock];
	STAssertTrue([concatenated isEqualToString:@"122333"], @"concatenated string is %@", concatenated);
}

- (void)testAny {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	BOOL wasFound = [_subject bk_any:validationBlock];
	STAssertEquals(_total,(NSInteger)3,@"total length of \"122\" is %d",_total);
	STAssertTrue(wasFound,@"matched object was found");
}

- (void)testAll {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 444) ? YES : NO;
		return match;
	};
	
	BOOL allMatched = [_subject bk_all:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertTrue(allMatched, @"Not all values matched");
}

- (void)testNone {
	BOOL(^validationBlock)(id) = ^(NSString *obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 1) ? YES : NO;
		return match;
	};
	
	BOOL noneMatched = [_subject bk_none:validationBlock];
	STAssertEquals(_total,(NSInteger)6,@"total length of \"122333\" is %d",_total);
	STAssertTrue(noneMatched, @"Some values matched");
}

@end
