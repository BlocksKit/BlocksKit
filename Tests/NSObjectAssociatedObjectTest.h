//
//  NSObjectAssociatedObjectTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSObject+AssociatedObjects.h>

@interface NSObjectAssociatedObjectTest : SenTestCase

- (void)testAssociatedRetainValue;
- (void)testAssociatedCopyValue;
- (void)testAssociatedAssignValue;
- (void)testAssociatedNotFound;

@end
