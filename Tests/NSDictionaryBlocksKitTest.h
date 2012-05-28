//
//  NSDictionaryBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSDictionaryBlocksKitTest : GHTestCase

- (void)testEach;
- (void)testMatch;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;
- (void)testAny;
- (void)testAll;
- (void)testNone;

@end
