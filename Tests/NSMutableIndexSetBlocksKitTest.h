//
//  NSMutableIndexSetBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSMutableIndexSet+BlocksKit.h>

@interface NSMutableIndexSetBlocksKitTest : SenTestCase

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedNone;

@end
