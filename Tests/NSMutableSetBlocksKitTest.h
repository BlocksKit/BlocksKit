//
//  NSMutableSetBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSMutableSet+BlocksKit.h>

@interface NSMutableSetBlocksKitTest : SenTestCase

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
