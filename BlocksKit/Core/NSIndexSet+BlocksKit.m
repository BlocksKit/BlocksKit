//
//  NSIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSIndexSet+BlocksKit.h"

@implementation NSIndexSet (BlocksKit)

- (void)bk_each:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (void)bk_apply:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (NSUInteger)bk_match:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];
}

- (NSIndexSet *)bk_select:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];

	if (!list.count) return nil;
	return list;
}

- (NSIndexSet *)bk_reject:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);
	return [self bk_select:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (NSIndexSet *)bk_map:(NSUInteger (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableIndexSet *list = [NSMutableIndexSet indexSet];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[list addIndex:block(idx)];
	}];

	if (!list.count) return nil;
	return list;
}

- (NSArray *)bk_mapIndex:(id (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		id value = block(idx) ?: [NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (BOOL)bk_any:(BOOL (^)(NSUInteger index))block {
	return [self bk_match:block] != NSNotFound;
}

- (BOOL)bk_none:(BOOL (^)(NSUInteger index))block {
	return [self bk_match:block] == NSNotFound;
}

- (BOOL)bk_all:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (!block(idx)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end
