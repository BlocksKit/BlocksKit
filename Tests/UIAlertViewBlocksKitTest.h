//
//  UIAlertViewBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface UIAlertViewBlocksKitTest : GHTestCase

- (void)testInit;
- (void)testAddButtonWithHandler;
- (void)testSetCancelButtonWithHandler;
- (void)testDelegationBlocks;

@end
