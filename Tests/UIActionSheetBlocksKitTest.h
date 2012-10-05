//
//  UIActionSheetBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/UIActionSheet+BlocksKit.h>

@interface UIActionSheetBlocksKitTest : SenTestCase

- (void)testInit;
- (void)testAddButtonWithHandler;
- (void)testSetDestructiveButtonWithHandler;
- (void)testSetCancelButtonWithHandler;
- (void)testDelegationBlocks;

@end
