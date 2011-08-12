//
//  NSSetBlocksKitTest.h
//  %PROJECT
//
//  Created by WU Kai on 7/4/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSSetBlocksKitTest : GHTestCase {
    NSSet *_subject;
    NSInteger _total;
}

- (void)testEach;
- (void)testMatch;
- (void)testNotMatch;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;
- (void)testReduceWithBlock;

@end
