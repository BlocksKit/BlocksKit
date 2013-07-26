//
//  NSObjectAssociatedObjectTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

@interface NSObjectAssociatedObjectTest : SenTestCase

- (void)testAssociatedRetainValue;
- (void)testAssociatedCopyValue;
- (void)testAssociatedWeakValue;
- (void)testAssociatedNotFound;

@end
