//
//  NSObjectBlockObservationTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>

@interface NSObjectBlockObservationTest : SenTestCase

- (void)testBoolKeyValueObservation;
- (void)testNSNumberKeyValueObservation;
- (void)testNSArrayKeyValueObservation;
- (void)testNSSetKeyValueObservation;
- (void)testMultipleKeyValueObservation;
- (void)testMultipleOnlyOneKeyValueObservation;


@end
