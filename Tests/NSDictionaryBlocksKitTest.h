//
//  NSDictionaryBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <Blockskit/NSDictionary+BlocksKit.h>

@interface NSDictionaryBlocksKitTest : SenTestCase

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
