//
//  NSMutableIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSMutableIndexSet+BlocksKit.h"

@implementation NSMutableIndexSet (BlocksKit)

- (void)bk_performSelect:(BOOL (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return !block(idx);
	}];

	if (!list.count) return;
	[self removeIndexes:list];
}

- (void)bk_performReject:(BOOL (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);
	return [self bk_performSelect:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (void)bk_performMap:(NSUInteger (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);

	NSMutableIndexSet *new = [self mutableCopy];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[new addIndex:block(idx)];
	}];

	[self removeAllIndexes];
	[self addIndexes:new];
}

@end
