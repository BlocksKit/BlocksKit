//
//  NSMutableIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSMutableIndexSet+BlocksKit.h"

@implementation NSMutableIndexSet (BlocksKit)

- (void)performSelect:(BKIndexValidationBlock)block {
	NSParameterAssert(block != nil);
	
	
	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return !block(idx);
	}];
	
	if (!list.count)
		return;
	
	[self removeIndexes:list];
}

- (void)performReject:(BKIndexValidationBlock)block {
	return [self performSelect:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (void)performMap:(BKIndexTransformBlock)block {
	NSParameterAssert(block != nil);
	
	NSMutableIndexSet *new = [self mutableCopy];
	
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[new addIndex:block(idx)];
	}];
	
	[self removeAllIndexes];
	[self addIndexes: new];
}

@end
