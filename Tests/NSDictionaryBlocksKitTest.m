//
//  NSDictionaryBlocksKitTest.m
//  BlocksKit
//
//  Created by WU Kai on 7/3/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import "NSDictionaryBlocksKitTest.h"


@implementation NSDictionaryBlocksKitTest

- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
    _subject = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1],@"1",
        [NSNumber numberWithInteger:2],@"2",
        [NSNumber numberWithInteger:3],@"3",
        nil
    ];
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
    BKKeyValueBlock keyValueBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
    };

    [_subject each:keyValueBlock];
    GHAssertEquals(_total,12,@"2*(1+2+3) = %d",_total);
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

@end
