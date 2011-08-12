//
//  NSMutableArrayBlocksKitTest.h
//  %PROJECT
//
//  Created by WU Kai on 7/8/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSMutableArrayBlocksKitTest : GHTestCase {
    NSMutableArray *_subject;
    NSInteger _total;
}
@property (nonatomic,retain) NSMutableArray *subject;

- (void)testSelect;
- (void)testSelectedNone;
- (void)testReject;
- (void)testRejectedAll;
- (void)testMap;

@end
