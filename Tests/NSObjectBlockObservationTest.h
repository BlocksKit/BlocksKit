//
//  NSObjectBlockObservationTest.h
//  BlocksKit Unit Tests
//

#import <SenTestingKit/SenTestingKit.h>
#import <BlocksKit/NSObject+BlockObservation.h>

@interface NSObjectBlockObservationTest : SenTestCase

- (void)testBoolKeyValueObservation;
- (void)testNSNumberKeyValueObservation;
- (void)testNSArrayKeyValueObservation;
- (void)testNSSetKeyValueObservation;
- (void)testMultipleKeyValueObservation;
- (void)testMultipleOnlyOneKeyValueObservation;


@end
