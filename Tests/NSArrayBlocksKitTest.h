//
//  NSArrayBlocksKitTest.h
//  BlocksKit
//
//  Created by WU Kai on 7/3/11.
//  Copyright 2011 Dizzy Technology. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSArrayBlocksKitTest : GHTestCase {
    NSArray *_subject;
    NSInteger _total;
}

- (void)testEach;
- (void)testMatch;
- (void)testNotMatch;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedNone;
- (void)testMap;
- (void)testReduceWithBlock;

@end
