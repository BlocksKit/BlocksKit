//
//  NSMutableDictionaryBlocksKitTest.m
//  BlocksKit Unit Tests
//

#import "NSMutableDictionaryBlocksKitTest.h"
#import <BlocksKit/BlocksKit.h>

@implementation NSMutableDictionaryBlocksKitTest {
	NSMutableDictionary *_subject;
	NSInteger _total;
}

- (void)setUp {
	_subject = [@{
		@"1" : @(1),
		@"2" : @(2),
		@"3" : @(3)
	} mutableCopy];
	_total = 0;
}

- (void)testSelect {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] < 3 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	STAssertEqualObjects(_subject,target,@"selected dictionary is %@",_subject);
}

- (void)testSelectedNone {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL select = [value intValue] > 4 ? YES : NO;
		return select;
	};
	[_subject bk_performSelect:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"no item is selected");
}

- (void)testReject {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] > 2 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{ @"1" : @(1), @"2" : @(2) };
	STAssertEqualObjects(_subject,target,@"dictionary after reject is %@",_subject);
}

- (void)testRejectedAll {
	BOOL(^validationBlock)(id, id) = ^(id key,id value) {
		_total += [value intValue] + [key intValue];
		BOOL reject = [value intValue] < 4 ? YES : NO;
		return reject;
	};
	[_subject bk_performReject:validationBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	STAssertEquals(_subject.count,(NSUInteger)0,@"all items are rejected");
}

- (void)testMap {
	id(^transformBlock)(id, id) = ^id(id key,id value) {
		_total += [value intValue] + [key intValue];
		return @(_total);
	};
	[_subject bk_performMap:transformBlock];
	STAssertEquals(_total,(NSInteger)12,@"2*(1+2+3) = %d",_total);
	NSDictionary *target = @{
		@"1" : @(2),
		@"2" : @(6),
		@"3" : @(12)
	};
	STAssertEqualObjects(_subject,target,@"transformed dictionary is %@",_subject);
}

@end
