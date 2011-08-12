//
//  NSArrayBlocksKitTest.m
//  %PROJECT
//
//  Created by WU Kai on 7/3/11.
//

#import "NSArrayBlocksKitTest.h"

@implementation NSArrayBlocksKitTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    _subject = [NSArray arrayWithObjects:@"1",@"22",@"333",nil];
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
  // Run before each test method
  _total = 0;
}

- (void)tearDown {
  // Run after each test method
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
    NSArray *found = [_subject select:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSArray *target = [NSArray arrayWithObjects:@"1",@"22",nil];
    GHAssertEqualObjects(found,target,@"selected items are %@",found);
}

- (void)testSelectedNone {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] > 400) ? YES : NO;
        return match;
    };
    NSArray *found = [_subject select:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    GHAssertNil(found,@"no item is selected");
}

- (void)testReject {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] > 300) ? YES : NO;
        return match;
    };
    NSArray *left = [_subject reject:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSArray *target = [NSArray arrayWithObjects:@"1",@"22",nil];
    GHAssertEqualObjects(left,target,@"not rejected items are %@",left);
}

- (void)testRejectedAll {
    BKValidationBlock validationBlock = ^(id obj) {
        _total += [obj length];
        BOOL match = ([obj intValue] < 400) ? YES : NO;
        return match;
    };
    NSArray *left = [_subject reject:validationBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    GHAssertNil(left,@"all items are rejected");
}

- (void)testMap {
    BKTransformBlock transformBlock = ^id(id obj) {
        _total += [obj length];
        return [obj substringToIndex:1];
    };
    NSArray *transformed = [_subject map:transformBlock];

    GHAssertEquals(_total,6,@"total length of \"122333\" is %d",_total);
    NSArray *target = [NSArray arrayWithObjects:@"1",@"2",@"3",nil];
    GHAssertEqualObjects(transformed,target,@"transformed items are %@",transformed);
}

- (void)testReduceWithBlock {
    BKAccumulationBlock accumlationBlock = ^id(id sum,id obj) {
        return [sum stringByAppendingString:obj];
    };
    NSString *concatenated = [_subject reduce:@"" withBlock:accumlationBlock];
    GHAssertEqualStrings(concatenated,@"122333",@"concatenated string is %@",concatenated);
}
@end
