//
//  NSObjectBlocksKitTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>
#import "BKAsyncTestCase.h"

@interface NSObjectBlocksKitTest : BKAsyncTestCase

- (void)testPerformBlockAfterDelay;
- (void)testClassPerformBlockAfterDelay;
- (void)testCancel;

@end
