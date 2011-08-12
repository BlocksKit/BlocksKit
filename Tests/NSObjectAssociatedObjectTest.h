//
//  NSObjectAssociatedObjectTest.h
//  %PROJECT
//
//  Created by WU Kai on 7/6/11.
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSObjectAssociatedObjectTest : GHTestCase {
}

- (void)testAssociatedRetainValue;
- (void)testAssociatedCopyValue;
- (void)testAssociatedAssignValue;
- (void)testAssociatedNotFound;

@end
