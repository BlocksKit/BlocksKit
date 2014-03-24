//
//  NSMutableDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//
//  Contributed by Kai Wu.
//

#import <XCTest/XCTest.h>
#import <BlocksKit/NSMutableDictionary+BlocksKit.h>

@interface NSMutableDictionaryBlocksKitTest : XCTestCase

@end

@implementation NSMutableDictionaryBlocksKitTest {
	NSMutableDictionary *_subject;
}

- (void)setUp {
	_subject = [@{
		@"1" : @(1),
		@"2" : @(2),
		@"3" : @(3)
	} mutableCopy];
}

- (void)testSelect {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL select = [value integerValue] < 3 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];
	
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	XCTAssertEqualObjects(_subject, target, @"selected dictionary is %@", _subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL select = [value integerValue] > 4 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];
	
	XCTAssertEqual(_subject.count, 0, @"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL reject = [value integerValue] > 2 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];
	
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	XCTAssertEqualObjects(_subject,target,@"dictionary after reject is %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key, NSNumber *value) {
		BOOL reject = [value integerValue] < 4 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];
	
	XCTAssertEqual(_subject.count, 0, @"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id, id) = ^(id key, NSNumber *value) {
		return @([value integerValue] * 2);
	};
	[_subject bk_performMap:transformBlock];
	
	NSDictionary *target = @{
		@"1" : @(2),
		@"2" : @(4),
		@"3" : @(6)
	};
	XCTAssertEqualObjects(_subject, target, @"transformed dictionary is %@", _subject);
}

@end
