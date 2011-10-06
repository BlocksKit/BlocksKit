//
//  NSObjectBlockObservationTest.h
//  BlocksKit Unit Tests
//

#import <GHUnitIOS/GHUnit.h>
#import "BlocksKit/BlocksKit.h"

@class SubjectKVCAndKVO;
@interface NSObjectBlockObservationTest : GHTestCase {
    SubjectKVCAndKVO *_subject; 
    NSInteger _total;
}
@property (nonatomic,retain) SubjectKVCAndKVO *subject;

- (void)testBoolKeyValueObservation;
- (void)testNSNumberKeyValueObservation;
- (void)testNSArrayKeyValueObservation;
- (void)testNSSetKeyValueObservation;

@end
