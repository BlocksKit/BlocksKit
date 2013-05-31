//
//  NSIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSIndexSet+BlocksKit.h"

@implementation NSIndexSet (BlocksKit)

- (void)each:(BKIndexBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (void)apply:(BKIndexBlock)block {
	NSParameterAssert(block != nil);
	
	[self enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (NSUInteger)match:(BKIndexValidationBlock)block {
	NSParameterAssert(block != nil);
	
	return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];
}

- (NSIndexSet *)select:(BKIndexValidationBlock)block {
	NSParameterAssert(block != nil);
	
	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];
	
	if (!list.count)
		return nil;
	
	return list;
}

- (NSIndexSet *)reject:(BKIndexValidationBlock)block {  
	return [self select:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (NSIndexSet *)map:(BKIndexTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableIndexSet *list = [NSMutableIndexSet indexSet];
	
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[list addIndex:block(idx)];
	}];
	
	if (!list.count)
		return nil;
	
	return list;
}

- (NSArray *)mapIndex:(BKIndexMapBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
	
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		id value = block(idx);
		if (!value)
			value = [NSNull null];
		
		[result addObject:value];
	}];
	
	return result;
}

- (BOOL)any:(BKIndexValidationBlock)block {
	return [self match: block] != NSNotFound;
}

- (BOOL)none:(BKIndexValidationBlock)block {
	return [self match: block] == NSNotFound;
}

- (BOOL)all:(BKIndexValidationBlock)block {
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
