//
//  UIActionSheetBlocksKitTest.h
//  BlocksKit
//
//  Created by WU Kai on 7/7/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface UIActionSheetBlocksKitTest : GHTestCase {
    UIActionSheet *_subject;
}
@property (nonatomic,retain) UIActionSheet *subject;

- (void)testInit;
- (void)testAddButtonWithHandler;
- (void)testSetDestructiveButtonWithHandler;
- (void)testSetCancelButtonWithHandler;
- (void)testDelegationBlocks;

@end
