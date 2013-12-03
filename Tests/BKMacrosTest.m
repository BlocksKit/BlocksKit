//
//  BKMacrosTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Nikolaj Schumacher
//

#import <XCTest/XCTest.h>
#import <BlocksKit/BKMacros.h>

@interface BKMacrosTest : XCTestCase
@end

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
    XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
}

- (void)testApply {
    BK_APPLY(_subject, @synchronized(self) {
        _total += [(NSString *)obj length];
    });
    XCTAssertEqual(_total, (NSInteger)6, @"total length of \"122333\" is %ld", (long)_total);
}

- (void)testMap {
    NSArray *transformed = BK_MAP(_subject, [obj substringToIndex:1]);
    NSArray *target = @[ @"1", @"2", @"3" ];
    XCTAssertEqualObjects(transformed, target, @"transformed items are %@", transformed);
}

- (void)testSelect {
    NSArray *found = BK_SELECT(_subject, ([obj intValue] < 300) ? YES : NO);
    NSArray *target = @[ @"1", @"22" ];
    XCTAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testReject {
    NSArray *left = BK_REJECT(_subject, ([obj intValue] > 300) ? YES : NO);
    NSArray *target = @[ @"1", @"22" ];
    XCTAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testMatch {
    id found = BK_MATCH(_subject, ([obj intValue] == 22) ? YES : NO);
    XCTAssertEqual(found, @"22", @"matched object is %@", found);
}

- (void)testReduce {
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingString:b]);
    XCTAssertTrue([concatenated isEqualToString: @"122333"], @"concatenated string is %@", concatenated);
}

#pragma mark - 2nd array tests

- (void)testEachWithSecondArray {
    BK_EACH(_subject, _total += [(NSString *)obj length] * [(NSString *)BK_NEXT(_subject2) length];);
    XCTAssertEqual(_total, (NSInteger)1*1+2*2+3*3, @"product sum of arrays is %ld", (long)_total);
}

- (void)testMapWithSecondArray {
    NSArray *transformed = BK_MAP(_subject, NEXT(_subject2));
    XCTAssertEqualObjects(transformed, _subject2, @"transformed items are %@", transformed);
}

- (void)testSelectWithSecondArray {
    NSArray *found = BK_SELECT(_subject2, ([NEXT(_subject) intValue] < 300) ? YES : NO);
    NSArray *target = @[ @"a", @"bb" ];
    XCTAssertEqualObjects(found, target, @"selected items are %@", found);
}

- (void)testRejectWithSecondArray {
    NSArray *left = BK_REJECT(_subject2, ([NEXT(_subject) intValue] > 300) ? YES : NO);
    NSArray *target = @[ @"a", @"bb" ];
    XCTAssertEqualObjects(left, target, @"not rejected items are %@", left);
}

- (void)testMatchWithSecondArray {
    id found = BK_MATCH(_subject2, ([NEXT(_subject) intValue] == 22) ? YES : NO);
    XCTAssertEqual(found, @"bb", @"matched object is %@", found);
}

- (void)testReduceWithSecondArray {
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingFormat:@"%@%@", b, NEXT(_subject2)]);
    XCTAssertTrue([concatenated isEqualToString: @"1a22bb333ccc"], @"concatenated string is %@", concatenated);
}

#pragma mark - multiple array test

- (void)testReduceWithMultipleArrays {
    NSArray *subject3 = @[ @"_", @"__", @"___" ];
    NSString *concatenated = BK_REDUCE(_subject, @"", [a stringByAppendingFormat:@"%@%@%@", b, NEXT(_subject2), NEXT(subject3)]);
    XCTAssertTrue([concatenated isEqualToString: @"1a_22bb__333ccc___"], @"concatenated string is %@", concatenated);
}

@end
