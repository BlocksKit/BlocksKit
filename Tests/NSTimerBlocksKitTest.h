//
//  NSTimerBlocksKitTest.h
//  BlocksKit
//
//  Created by WU Kai on 7/5/11.
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
