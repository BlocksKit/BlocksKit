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

@end
