//
//  NSSetBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

@interface NSSetBlocksKitTest : SenTestCase

- (void)testEach;
- (void)testMatch;
- (void)testNotMatch;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;
- (void)testReduceWithBlock;
- (void)testAny;
- (void)testAll;
- (void)testNone;

@end
