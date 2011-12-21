//
//  NSObjectAssociatedObjectTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSObjectAssociatedObjectTest : GHTestCase

- (void)testAssociatedRetainValue;
- (void)testAssociatedCopyValue;
- (void)testAssociatedAssignValue;
- (void)testAssociatedNotFound;

@end
