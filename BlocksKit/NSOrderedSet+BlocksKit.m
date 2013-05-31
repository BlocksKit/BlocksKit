//
//  NSOrderedSet+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/5/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "NSOrderedSet+BlocksKit.h"

@implementation NSOrderedSet (BlocksKit)

- (void)each:(BKSenderBlock)block {
	NSParameterAssert(block != nil);

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (void)apply:(BKSenderBlock)block {
	NSParameterAssert(block != nil);

	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (id)match:(BKValidationBlock)block {
	NSParameterAssert(block != nil);

	NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}];

	if (index == NSNotFound)
		return nil;

	return self[index];
}

- (NSOrderedSet *)select:(BKValidationBlock)block {
	NSParameterAssert(block != nil);

	NSArray *objects = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}]];

	if (!objects.count)
		return [[self class] orderedSet];

	return [[self class] orderedSetWithArray: objects];
}

- (NSOrderedSet *)reject:(BKValidationBlock)block {
	return [self select:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (NSOrderedSet *)map:(BKTransformBlock)block {
	NSParameterAssert(block != nil);

	NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity: self.count];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = block(obj);
		if (!value)
			value = [NSNull null];

		[result addObject:value];
	}];

	return result;
}

- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block {
	NSParameterAssert(block != nil);

	__block id result = initial;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		result = block(result, obj);
	}];

	return result;
}

- (BOOL)any:(BKValidationBlock)block {
	return [self match: block] != nil;
}

- (BOOL)none:(BKValidationBlock)block {
	return [self match: block] == nil;
}

- (BOOL) all: (BKValidationBlock)block {
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

- (BOOL) corresponds: (NSOrderedSet *) list withBlock: (BKKeyValueValidationBlock) block {
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
