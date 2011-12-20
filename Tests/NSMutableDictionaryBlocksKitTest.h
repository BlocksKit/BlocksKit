//
//  NSMutableDictionaryBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSMutableDictionaryBlocksKitTest : GHTestCase {
	NSMutableDictionary *_subject;
	NSInteger _total;
}
@property (nonatomic,retain) NSMutableDictionary *subject;

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
