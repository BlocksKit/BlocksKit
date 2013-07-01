//
//  NSMutableArray+BlocksKit.m
//  BlocksKit
//

#import "NSMutableArray+BlocksKit.h"

@implementation NSMutableArray (BlocksKit)

- (void)bk_performSelect:(BOOL (^)(id obj))block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return !block(obj);
	}];

	if (!list.count) return;
	[self removeObjectsAtIndexes:list];
}

- (void)bk_performReject:(BOOL (^)(id obj))block {
	NSParameterAssert(block != nil);
	return [self bk_performSelect:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (void)bk_performMap:(id (^)(id obj))block {
	NSParameterAssert(block != nil);

	NSMutableArray *new = [self mutableCopy];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = block(obj) ?: [NSNull null];
		if ([value isEqual:obj]) return;
		new[idx] = value;
	}];

	[self setArray:new];
}

@end
