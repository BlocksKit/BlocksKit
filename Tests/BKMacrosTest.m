#import "BKMacrosTest.h"
#import "BKMacros.h"

@implementation BKMacrosTest {
    NSArray *_subject;
    NSArray *_subject2;
    NSInteger _total;
}

- (void)setUp {
    _subject = @[ @"1", @"22", @"333" ];
    _subject2 = @[ @"a", @"bb", @"ccc" ];
    _total = 0;
}

#pragma mark - basic tests

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

#pragma mark - 2nd array tests

- (void)testEachWithSecondArray {
    BK_EACH(_subject, _total += [(NSString *)obj length] * [(NSString *)BK_NEXT(_subject2) length];);
    STAssertEquals(_total, (NSInteger)1*1+2*2+3*3, @"product sum of arrays is %d", _total);
}

- (void)testMapWithSecondArray {
    NSArray *transformed = BK_MAP(_subject, NEXT(_subject2));
    STAssertEqualObjects(transformed, _subject2, @"transformed items are %@", transformed);
}

- (void)testSelectWithSecondArray {
    NSArray *found = BK_SELECT(_subject2, ([NEXT(_subject) intValue] < 300) ? YES : NO);
    NSArray *target = @[ @"a", @"bb" ];
    STAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testRejectWithSecondArray {
    NSArray *left = BK_REJECT(_subject2, ([NEXT(_subject) intValue] > 300) ? YES : NO);
    NSArray *target = @[ @"a", @"bb" ];
    STAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testMatchWithSecondArray {
    id found = BK_MATCH(_subject2, ([NEXT(_subject) intValue] == 22) ? YES : NO);
    STAssertEquals(found, @"bb", @"matched object is %@", found);
}

- (void)testReduceWithSecondArray {
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingFormat:@"%@%@", b, NEXT(_subject2)]);
    STAssertTrue([concatenated isEqualToString: @"1a22bb333ccc"], @"concatenated string is %@", concatenated);
}

#pragma mark - multiple array test

- (void)testReduceWithMultipleArrays {
    NSArray *subject3 = @[ @"_", @"__", @"___" ];
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingFormat:@"%@%@%@", b, NEXT(_subject2), NEXT(subject3)]);
    STAssertTrue([concatenated isEqualToString: @"1a_22bb__333ccc___"], @"concatenated string is %@", concatenated);
}

@end
