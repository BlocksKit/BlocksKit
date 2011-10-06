//
//  NSMutableSetBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableSetBlocksKitTest.h"


@implementation NSMutableSetBlocksKitTest
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
    self.subject = [NSMutableSet setWithObjects:@"1",@"22",@"333",nil];
    _total = 0;
}

- (void)tearDown {
  // Run after each test method
}

- (void)testSelect {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] < 300) ? YES : NO;
        return match;
    };
    [_subject performSelect:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"22",nil];
    GHAssertEqualObjects(_subject,target,@"selected items are %@",_subject);
}

- (void)testSelectedNone {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] > 400) ? YES : NO;
        return match;
    };
    [_subject performSelect:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    GHAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] > 300) ? YES : NO;
        return match;
    };
    [_subject performReject:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"22",nil];
    GHAssertEqualObjects(_subject,target,@"not rejected items are %@",_subject);
}

- (void)testRejectedAll {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] < 400) ? YES : NO;
        return match;
    };
    [_subject performReject:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    GHAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
    BKTransformBlock transformBlock = ^id(id obj) {
        _total += [obj length];
        return [obj substringToIndex:1];
    };
    [_subject performMap:transformBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSMutableSet *target = [NSMutableSet setWithObjects:@"1",@"2",@"3",nil];
    GHAssertEqualObjects(_subject,target,@"transformed items are %@",_subject);
}

@end
