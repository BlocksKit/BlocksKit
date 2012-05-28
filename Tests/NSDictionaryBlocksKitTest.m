//
//  NSDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSDictionaryBlocksKitTest.h"


@implementation NSDictionaryBlocksKitTest {
	NSDictionary *_subject;
	NSInteger _total;
}

- (void)setUpClass {
	_subject = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSNumber numberWithInteger:1],@"1",
		[NSNumber numberWithInteger:2],@"2",
		[NSNumber numberWithInteger:3],@"3",
		nil];
}

- (void)tearDownClass {
	[_subject release];
}

- (void)setUp {
  _total = 0;
} 

- (void)testEach {
	BKKeyValueBlock keyValueBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
	};

	[_subject each:keyValueBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
}

- (void)testMatch {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject match:validationBlock];
	GHAssertEquals(_total,2,@"2*1 = %d",_total);
	GHAssertEqualObjects(selected,[NSNumber numberWithInteger:1],@"selected value is %@",selected);
}

- (void)testSelect {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject select:validationBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:1],@"1",
		[NSNumber numberWithInteger:2],@"2",
		nil
	];
	GHAssertEqualObjects(selected,target,@"selected dictionary is %@",selected);
}

- (void)testSelectedNone {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	NSDictionary *selected = [_subject select:validationBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	GHAssertFalse(selected.count, @"none item is selected");
}

- (void)testReject {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 3 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject reject:validationBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:3],@"3",
		nil
	];
	GHAssertEqualObjects(rejected,target,@"dictionary after rejection is %@",rejected);
}

- (void)testRejectedAll {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	NSDictionary *rejected = [_subject reject:validationBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	GHAssertFalse(rejected.count, @"all items are selected");
}

- (void)testMap {
	BKKeyValueTransformBlock transformBlock = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return [NSNumber numberWithInteger:_total];
	};
	NSDictionary *transformed = [_subject map:transformBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:2],@"1",
		[NSNumber numberWithInteger:6],@"2",
		[NSNumber numberWithInteger:12],@"3",
		nil
	];
	GHAssertEqualObjects(transformed,target,@"transformed dictionary is %@",transformed);
}

- (void)testAny {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	BOOL isSelected = [_subject any: validationBlock];
	GHAssertEquals(_total,2,@"2*1 = %d",_total);
	GHAssertEquals(isSelected, YES, @"found selected value is %i", isSelected);	
}

- (void)testAll {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 4 ? YES : NO;
		return select;
	};
	BOOL allSelected = [_subject all:validationBlock];
	GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
	GHAssertTrue(allSelected,@"all values matched test");
}

- (void)testNone {
	BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 2 ? YES : NO;
		return select;
	};
	BOOL noneSelected = [_subject all:validationBlock];
	GHAssertEquals(_total,6,@"2*(1+2) = %d",_total);
	GHAssertFalse(noneSelected,@"not all values matched test");
}

@end
