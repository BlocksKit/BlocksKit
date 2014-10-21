//
// Created by Agens AS for BlocksKit on 21.10.14.
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSMapTable+BlocksKit.h>

@interface NSMapTableBlocksKitTest : SenTestCase

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
