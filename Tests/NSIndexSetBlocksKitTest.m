//
//  NSIndexSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSIndexSetBlocksKitTest.h"


@implementation NSIndexSetBlocksKitTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
	// Run at start of all tests in the class
	NSRange r = {1,3};//1,2,3
	_subject = [NSIndexSet indexSetWithIndexesInRange:r];
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
	// Run before each test method
	_target = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",nil];
}

- (void)tearDown {
  // Run after each test method
}

- (void)testEach {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexBlock indexBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		[_target replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%d",index]];
	};
	[_subject each:indexBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);

	NSArray *target = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",nil];
	GHAssertEqualObjects(_target,target,@"the target array becomes %@",_target);
}

- (void)testMatch {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = NO;
		if (index%2 == 0 ) {
			[_target replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%d",index]];
			match = YES;
		}
		return match;
	};
	NSUInteger found = [_subject match:indexValidationBlock];
	GHAssertEqualStrings(order,@"12",@"the index loop order is %@",order);
	GHAssertTrue([[_target objectAtIndex:found] isEqual:@"2"],@"the target array becomes %@",_target);
}

- (void)testNotMatch {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = index > 4 ? YES : NO;
		return match;
	};
	NSUInteger found = [_subject match:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertTrue(found == NSNotFound,@"no items are found");
}

- (void)testSelect {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = index < 3 ? YES : NO; //1,2
		return match;
	};
	NSIndexSet *found = [_subject select:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	NSIndexSet *target = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)];
	GHAssertEqualObjects(found,target,@"the selected index set is %@",found);
}

- (void)testSelectedNone {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = index == 0 ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject select:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertNil(found,@"no index found");
}

- (void)testReject {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = [[_target objectAtIndex:index] isEqual: @"0"] ? YES : NO;
		return match;
	};
	NSIndexSet *found = [_subject reject:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertNil(found,@"all indexes are rejected");
}

- (void)testRejectedNone {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = [[_target objectAtIndex:index] isEqual: @"0"] ? NO : YES;
		return match;
	};
	NSIndexSet *found = [_subject reject:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertEqualObjects(found,_subject,@"all indexes that are not rejected %@",found);
}

@end
