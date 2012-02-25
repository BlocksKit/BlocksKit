//
//  NSArray+BlocksKit.m
//  BlocksKit
//

#import "NSArray+BlocksKit.h"

@implementation NSArray (BlocksKit)

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
	
	return [self objectAtIndex:index];
}

- (NSArray *)select:(BKValidationBlock)block {
	NSParameterAssert(block != nil);
	
	return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}]];
}

- (NSArray *)reject:(BKValidationBlock)block {
	return [self select:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (NSArray *)map:(BKTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
	
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
	
	__block id result = [initial retain];
	
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id new = block(result, obj);
		[result release];
		result = [new retain];
	}];
	
	return [result autorelease];
}

@end
