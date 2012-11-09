//
//  NSMutableDictionaryBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSMutableDictionary+BlocksKit.h>

@interface NSMutableDictionaryBlocksKitTest : SenTestCase

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
