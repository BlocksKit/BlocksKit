//
//  NSMutableDictionaryBlocksKitTest.m
//  %PROJECT
//
//  Created by WU Kai on 7/8/11.
//

#import "NSMutableDictionaryBlocksKitTest.h"


@implementation NSMutableDictionaryBlocksKitTest
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
    self.subject = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1],@"1",
        [NSNumber numberWithInteger:2],@"2",
        [NSNumber numberWithInteger:3],@"3",
        nil
    ];
    _total = 0;
}

- (void)tearDown {
  // Run after each test method
}  


- (void)testSelect {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] < 3 ? YES : NO;
        return select;
    };
    [_subject performSelect:validationBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
    NSMutableDictionary *target = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1],@"1",
        [NSNumber numberWithInteger:2],@"2",
        nil
    ];
    GHAssertEqualObjects(_subject,target,@"selected dictionary is %@",_subject);
}

- (void)testSelectedNone {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] > 4 ? YES : NO;
        return select;
    };
    [_subject performSelect:validationBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
    GHAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL reject = [value intValue] > 2 ? YES : NO;
        return reject;
    };
    [_subject performReject:validationBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
    NSMutableDictionary *target = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1],@"1",
        [NSNumber numberWithInteger:2],@"2",
        nil
    ];
    GHAssertEqualObjects(_subject,target,@"dictionary after reject is %@",_subject);
}

- (void)testRejectedAll {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL reject = [value intValue] < 4 ? YES : NO;
        return reject;
    };
    [_subject performReject:validationBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
    GHAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
    BKKeyValueTransformBlock transformBlock = ^id(id key,id value) {
        _total += [value intValue] + [key intValue];
        return [NSNumber numberWithInteger:_total];
    };
    [_subject performMap:transformBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
    NSMutableDictionary *target = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:2],@"1",
        [NSNumber numberWithInteger:6],@"2",
        [NSNumber numberWithInteger:12],@"3",
        nil
    ];
    GHAssertEqualObjects(_subject,target,@"transformed dictionary is %@",_subject);
}

@end
