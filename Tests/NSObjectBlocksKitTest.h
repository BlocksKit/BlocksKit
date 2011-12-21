//
//  NSObjectBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSObjectBlocksKitTest : GHAsyncTestCase

- (void)testPerformBlockAfterDelay;
- (void)testClassPerformBlockAfterDelay;
- (void)testCancel;

@end
