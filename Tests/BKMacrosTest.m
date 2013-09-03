#import "BKMacrosTest.h"
#import "BKMacros.h"

@implementation BKMacrosTest {
    NSArray *_subject;
    NSInteger _total;
}

- (void)setUp {
    _subject = @[ @"1", @"22", @"333" ];
    _total = 0;
}

- (void)testEach {
    BK_EACH(_subject, _total += [(NSString *)obj length];);
    STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testApply {
    BK_APPLY(_subject, @synchronized(self) {
        _total += [(NSString *)obj length];
    });
    STAssertEquals(_total, (NSInteger)6, @"total length of \"122333\" is %d", _total);
}

- (void)testMap {
    NSArray *transformed = BK_MAP(_subject, [obj substringToIndex:1]);
    NSArray *target = @[ @"1", @"2", @"3" ];
    STAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testSelect {
    NSArray *found = BK_SELECT(_subject, ([obj intValue] < 300) ? YES : NO);
    NSArray *target = @[ @"1", @"22" ];
    STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testReject {
    NSArray *left = BK_REJECT(_subject, ([obj intValue] > 300) ? YES : NO);
    NSArray *target = @[ @"1", @"22" ];
    STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testMatch {
    id found = BK_MATCH(_subject, ([obj intValue] == 22) ? YES : NO);
    STAssertEquals(found, @"22", @"matched object is %@", found);
}

- (void)testReduce {
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingString:b]);
    STAssertTrue([concatenated isEqualToString: @"122333"], @"concatenated string is %@", concatenated);
}

@end
