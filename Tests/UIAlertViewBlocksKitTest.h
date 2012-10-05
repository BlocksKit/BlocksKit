//
//  UIAlertViewBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>

@interface UIAlertViewBlocksKitTest : SenTestCase

- (void)testInit;
- (void)testAddButtonWithHandler;
- (void)testSetCancelButtonWithHandler;
- (void)testDelegationBlocks;

@end
