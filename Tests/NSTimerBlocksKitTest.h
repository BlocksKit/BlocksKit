//
//  NSTimerBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSTimerBlocksKitTest : GHAsyncTestCase {
	NSInteger _total;	
}

- (void)testScheduledTimer;
- (void)testRepeatedlyScheduledTimer;
- (void)testUnscheduledTimer;
- (void)testRepeatableUnscheduledTimer;

@end
