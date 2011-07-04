//
//  NSIndexSetBlocksKitTest.h
//  BlocksKit
//
//  Created by WU Kai on 7/4/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSIndexSetBlocksKitTest : GHTestCase {
    NSIndexSet *_subject;
    NSMutableArray  *_target;
}

- (void)testEach;
- (void)testMatch;
- (void)testNoMatch;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedNone;

@end
