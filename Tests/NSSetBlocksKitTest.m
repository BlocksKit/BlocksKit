//
//  NSSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSSetBlocksKitTest.h"

@implementation NSSetBlocksKitTest {
	NSSet *_subject;
	NSInteger _total;
}

- (void)setUpClass {
	_subject = [[NSSet alloc] initWithObjects:@"1",@"22",@"333",nil];
}

- (void)tearDownClass {
	[_subject release];
}

- (void)setUp {
	_total = 0;
}

- (void)testEach {
	BKSenderBlock senderBlock = ^(id sender) {
		_total += [sender length];
	};
	[_subject each:senderBlock];
	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
}

- (void)testMatch {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];

	//match: is functionally identical to select:, but will stop and return on the first match
	GHAssertEquals(_total,3,@"total length of \"122\" is %d",_total);
	GHAssertEquals(found,@"22",@"matched object is %@",found);
}

- (void)testNotMatch {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 4444) ? YES : NO;
		return match;
	};
	id found = [_subject match:validationBlock];

	//@return Returns the object if found, `nil` otherwise.
	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertNil(found,@"no matched object");
}

- (void)testSelect {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 300) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject select:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithObjects:@"1",@"22",nil];
	GHAssertEqualObjects(found,target,@"selected items are %@",found);
}

- (void)testSelectedNone {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 400) ? YES : NO;
		return match;
	};
	NSSet *found = [_subject select:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertFalse(found.count,@"no item is selected");
}

- (void)testReject {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] > 300) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject reject:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithObjects:@"1",@"22",nil];
	GHAssertEqualObjects(left,target,@"not rejected items are %@",left);
}

- (void)testRejectedAll {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 400) ? YES : NO;
		return match;
	};
	NSSet *left = [_subject reject:validationBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertFalse(left.count,@"all items are rejected");
}

- (void)testMap {
	BKTransformBlock transformBlock = ^id(id obj) {
		_total += [obj length];
		return [obj substringToIndex:1];
	};
	NSSet *transformed = [_subject map:transformBlock];

	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	NSSet *target = [NSSet setWithObjects:@"1",@"2",@"3",nil];
	GHAssertEqualObjects(transformed,target,@"transformed items are %@",transformed);
}

- (void)testReduceWithBlock {
	BKAccumulationBlock accumlationBlock = ^id(id sum,id obj) {
		return [sum stringByAppendingString:obj];
	};
	NSString *concatenated = [_subject reduce:@"" withBlock:accumlationBlock];
	GHAssertEqualStrings(concatenated,@"122333",@"concatenated string is %@",concatenated);
}

- (void)testAny {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] == 22) ? YES : NO;
		return match;
	};
	BOOL wasFound = [_subject any:validationBlock];
	
	// any: is functionally identical to select:, but will stop and return YES on the first match
	GHAssertEquals(_total,3,@"total length of \"122\" is %d",_total);
	GHAssertTrue(wasFound,@"matched object was found");
}

- (void)testAll {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 444) ? YES : NO;
		return match;
	};
	
	BOOL allMatched = [_subject all: validationBlock];
	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertTrue(allMatched, @"Not all values matched");
}

- (void)testNone {
	BKValidationBlock validationBlock = ^(id obj) {
		_total += [obj length];
		BOOL match = ([obj intValue] < 1) ? YES : NO;
		return match;
	};
	
	BOOL noneMatched = [_subject none: validationBlock];
	GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
	GHAssertTrue(noneMatched, @"Some values matched");
}

@end
