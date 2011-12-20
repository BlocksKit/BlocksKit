//
//  NSMutableSetBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSMutableSetBlocksKitTest : GHTestCase {
	NSMutableSet *_subject;
	NSInteger _total;
}
@property (nonatomic,retain) NSMutableSet *subject;

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
