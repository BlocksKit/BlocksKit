//
//  NSMutableIndexSetBlocksKitTest.h
//  %PROJECT
//
//  Created by WU Kai on 7/8/11.
//


#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSMutableIndexSetBlocksKitTest : GHTestCase {
    NSMutableIndexSet *_subject;
    NSMutableArray  *_target;
}
@property (nonatomic,retain) NSMutableIndexSet *subject;

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedNone;

@end
