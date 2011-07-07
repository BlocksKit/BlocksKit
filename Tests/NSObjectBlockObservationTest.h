//
//  NSObjectBlockObservationTest.h
//  BlocksKit
//
//  Created by WU Kai on 7/5/11.
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
- (void)testKeyValueObservationOnOperationQueue;

@end
