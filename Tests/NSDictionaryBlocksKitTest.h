//
//  NSDictionaryBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSDictionaryBlocksKitTest : GHTestCase {
	NSDictionary *_subject;
	NSInteger _total;
}

- (void)testEach;
- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
