//
//  NSIndexSet+BlocksKit.m
//  BlocksKit
//

#import "NSIndexSet+BlocksKit.h"

@implementation NSIndexSet (BlocksKit)

- (void)each:(BKIndexBlock)block {
	NSParameterAssert(block);
	
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        block(idx);
    }];
}

- (void)apply:(BKIndexBlock)block {
	NSParameterAssert(block);
	
	[self enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (NSUInteger)match:(BKIndexValidationBlock)block {
	NSParameterAssert(block);
	
    return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return block(idx);
    }];
}

- (NSIndexSet *)select:(BKIndexValidationBlock)block {
	NSParameterAssert(block);
	
    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return block(idx);
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSIndexSet *)reject:(BKIndexValidationBlock)block {  
	NSParameterAssert(block);

    NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return !block(idx);
    }];
    
    if (!list.count)
        return nil;
    
    return list;     
}

- (NSIndexSet *)map:(BKIndexTransformBlock)block {
	NSParameterAssert(block);
	
    NSMutableIndexSet *list = [NSMutableIndexSet indexSet];
    
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [list addIndex:block(idx)];
    }];
    
    if (!list.count)
        return nil;
    
    return list;
}

@end
