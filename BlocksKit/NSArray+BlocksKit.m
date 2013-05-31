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
	
	return self[index];
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

- (BOOL)all:(BKValidationBlock)block {
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

- (BOOL) corresponds: (NSArray *) list withBlock: (BKKeyValueValidationBlock) block {
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
