//
//  NSOrderedSet+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "NSOrderedSet+BlocksKit.h"

@implementation NSOrderedSet (BlocksKit)

- (void)bk_each:(BKSenderBlock)block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (void)bk_apply:(BKSenderBlock)block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (id)bk_match:(BKValidationBlock)block
{
	NSParameterAssert(block != nil);

	NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}];

	if (index == NSNotFound) return nil;
	return self[index];
}

- (NSOrderedSet *)bk_select:(BKValidationBlock)block
{
	NSParameterAssert(block != nil);

	NSArray *objects = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}]];

	if (!objects.count) return [[self class] orderedSet];
	return [[self class] orderedSetWithArray:objects];
}

- (NSOrderedSet *)bk_reject:(BKValidationBlock)block
{
	NSParameterAssert(block != nil);
	return [self bk_select:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (NSOrderedSet *)bk_map:(BKTransformBlock)block
{
	NSParameterAssert(block != nil);

	NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:self.count];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = block(obj) ?: [NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (id)bk_reduce:(id)initial withBlock:(BKAccumulationBlock)block
{
	NSParameterAssert(block != nil);

	__block id result = initial;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		result = block(result, obj);
	}];

	return result;
}

- (BOOL)bk_any:(BKValidationBlock)block
{
	return [self bk_match:block] != nil;
}

- (BOOL)bk_none:(BKValidationBlock)block
{
	return [self bk_match:block] == nil;
}

- (BOOL)bk_all:(BKValidationBlock)block
{
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (!block(obj)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

- (BOOL)bk_corresponds:(NSOrderedSet *)list withBlock:(BKKeyValueValidationBlock)block
{
	NSParameterAssert(block != nil);

	__block BOOL result = NO;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (idx < list.count) {
			id obj2 = list[idx];
			result = block(obj, obj2);
		} else {
			result = NO;
		}
		*stop = !result;
	}];

	return result;
}

@end
