//
// Created by Agens AS for BlocksKit on 21.10.14.
//

#import "NSMapTableBlocksKitTest.h"

@implementation NSMapTableBlocksKitTest {
    NSMapTable *_subject;
    NSInteger _total;
}

- (void)setUp {

    _subject = [NSMapTable strongToStrongObjectsMapTable];
    [_subject setObject:@1 forKey:@"1"];
    [_subject setObject:@2 forKey:@"2"];
    [_subject setObject:@3 forKey:@"3"];

    _total = 0;
}

- (void)tearDown {
    _subject = nil;
}

- (void)testEach {
    BKKeyValueBlock keyValueBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
    };

    [_subject each:keyValueBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
}

- (void)testMatch {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] < 3 ? YES : NO;
        return select;
    };
    NSMapTable *selected = [_subject match:validationBlock];
    STAssertEquals(_total, (NSInteger)2, @"2*1 = %d", _total);
    STAssertEqualObjects(selected, @(1), @"selected value is %@", selected);
}

- (void)testSelect {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] < 3 ? YES : NO;
        return select;
    };
    NSMapTable *selected = [_subject select: validationBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);

    NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
    [target setObject:@1 forKey:@"1"];
    [target setObject:@2 forKey:@"2"];

    STAssertEqualObjects(selected, target, @"selected maptable is %@", selected);
}

- (void)testSelectedNone {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] > 4 ? YES : NO;
        return select;
    };
    NSMapTable *selected = [_subject select: validationBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
    STAssertTrue(selected.count == 0, @"none item is selected");
}

- (void)testReject {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL reject = [value intValue] < 3 ? YES : NO;
        return reject;
    };
    NSMapTable *rejected = [_subject reject: validationBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);

    NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
    [target setObject:@3 forKey:@"3"];

    STAssertEqualObjects(rejected, target, @"maptable after rejection is %@", rejected);
}

- (void)testRejectedAll {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL reject = [value intValue] < 4 ? YES : NO;
        return reject;
    };
    NSMapTable *rejected = [_subject reject: validationBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
    STAssertTrue(rejected.count == 0, @"all items are selected");
}

- (void)testMap {
    BKKeyValueTransformBlock transformBlock = ^id(NSString *key, NSNumber *value) {
        return @([key intValue] + [value intValue]);
    };
    NSMapTable *transformed = [_subject map: transformBlock];

    NSMapTable *target = [NSMapTable strongToStrongObjectsMapTable];
    [target setObject:@2 forKey:@"1"];
    [target setObject:@4 forKey:@"2"];
    [target setObject:@6 forKey:@"3"];

    STAssertEqualObjects(transformed,target,@"transformed maptable is %@",transformed);
}

- (void)testAny {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] < 3 ? YES : NO;
        return select;
    };
    BOOL isSelected = [_subject any: validationBlock];
    STAssertEquals(_total, (NSInteger)2, @"2*1 = %d", _total);
    STAssertEquals(isSelected, YES, @"found selected value is %i", isSelected);
}

- (void)testAll {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        _total += [value intValue] + [key intValue];
        BOOL select = [value intValue] < 4 ? YES : NO;
        return select;
    };
    BOOL allSelected = [_subject all: validationBlock];
    STAssertEquals(_total, (NSInteger)12, @"2*(1+2+3) = %d", _total);
    STAssertTrue(allSelected, @"all values matched test");
}

- (void)testNone {
    BKKeyValueValidationBlock validationBlock = ^(id key,id value) {
        BOOL select = [value intValue] < 2 ? YES : NO;
        return select;
    };
    BOOL noneSelected = [_subject all: validationBlock];
    STAssertFalse(noneSelected, @"not all values matched test");
}

@end
