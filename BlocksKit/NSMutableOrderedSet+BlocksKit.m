//
//  NSMutableOrderedSet+BlocksKit.m
//  BlocksKit
//
//  Created by Zachary Waldowski on 10/6/12.
//  Copyright (c) 2012 Pandamonia LLC. All rights reserved.
//

#import "NSMutableOrderedSet+BlocksKit.h"

@implementation NSMutableOrderedSet (BlocksKit)

- (void)performSelect:(BKValidationBlock)block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return !block(obj);
	}];

	if (!list.count)
		return;

	[self removeObjectsAtIndexes:list];
}

- (void)performReject:(BKValidationBlock)block {
	return [self performSelect:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (void)performMap:(BKTransformBlock)block {
	NSParameterAssert(block != nil);

	NSMutableIndexSet *newIndexes = [NSMutableIndexSet indexSet];
	NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity: self.count];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = block(obj);

		if (!value)
			value = [NSNull null];

		if ([value isEqual:obj])
			return;

		[newIndexes addIndex: idx];
		[newObjects addObject: obj];
	}];

	[self replaceObjectsAtIndexes: newIndexes withObjects: newObjects];	
}

@end
