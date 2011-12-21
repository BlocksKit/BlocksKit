//
//  NSObjectBlockObservationTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@interface NSObjectBlockObservationTest : GHTestCase

- (void)testBoolKeyValueObservation;
- (void)testNSNumberKeyValueObservation;
- (void)testNSArrayKeyValueObservation;
- (void)testNSSetKeyValueObservation;

@end
