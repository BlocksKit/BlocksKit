//
//  NSMutableIndexSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableIndexSetBlocksKitTest.h"


@implementation NSMutableIndexSetBlocksKitTest {
	NSMutableIndexSet *_subject;
	NSMutableArray *_target;
}

- (void)setUp {
	_target = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0",nil];
	_subject = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 3)];
}

- (void)tearDown {
	[_target release];
	[_subject release];
}

- (void)testSelect {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = index < 3 ? YES : NO; //1,2
		return match;
	};
	[_subject performSelect:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	NSMutableIndexSet *target = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1,2)];
	GHAssertEqualObjects(_subject,target,@"the selected index set is %@",_subject);
}

- (void)testSelectedNone {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = index == 0 ? YES : NO;
		return match;
	};
	[_subject performSelect:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertEquals(_subject.count,(NSUInteger)0,@"no index found");
}

- (void)testReject {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = [[_target objectAtIndex:index] isEqual: @"0"] ? YES : NO;
		return match;
	};
	[_subject performReject:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	GHAssertEquals(_subject.count,(NSUInteger)0,@"all indexes are rejected");
}

- (void)testRejectedNone {
	__block NSMutableString *order = [NSMutableString string];
	BKIndexValidationBlock indexValidationBlock = ^(NSUInteger index) {
		[order appendFormat:@"%d",index];
		BOOL match = [[_target objectAtIndex:index] isEqual: @"0"] ? NO : YES;
		return match;
	};
	[_subject performReject:indexValidationBlock];
	GHAssertEqualStrings(order,@"123",@"the index loop order is %@",order);
	NSMutableIndexSet *target = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1,3)];
	GHAssertEqualObjects(_subject,target,@"the rejected index set is %@",_subject);
}

@end
