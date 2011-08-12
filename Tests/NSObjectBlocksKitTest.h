//
//  NSObjectBlocksKitTest.h
//  %PROJECT
//
//  Created by WU Kai on 7/4/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSObjectBlocksKitTest : GHAsyncTestCase {
    NSMutableString *_subject;    
}
@property (nonatomic,retain) NSMutableString *subject; //subject is not thread safe

- (void)testPerformBlockAfterDelay;
- (void)testClassPerformBlockAfterDelay;
- (void)testCancel;
@end
