//
//  NSMutableIndexSetBlocksKitTest.m
//  %PROJECT
//
//  Created by WU Kai on 7/8/11.
//

#import "NSMutableIndexSetBlocksKitTest.h"


@implementation NSMutableIndexSetBlocksKitTest
@synthesize subject=_subject;

- (void)dealloc {
    [_subject release];
    [super dealloc];
}

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
    _target = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",nil];
    NSRange r = {1,3};//1,2,3
    self.subject = [NSMutableIndexSet indexSetWithIndexesInRange:r];
}

- (void)tearDown {
  // Run after each test method
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
