//
//  NSArray+BlocksKit.m
//  BlocksKit
//

#import "NSArray+BlocksKit.h"

@implementation NSArray (BlocksKit)

- (void)each:(BKSenderBlock)block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (id)match:(BKValidationBlock)block {
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound)
        return nil;
    
    return [self objectAtIndex:index];
}

- (NSArray *)select:(BKValidationBlock)block {
    NSArray *result = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
    
    if (!result.count)
        return nil;
    
    return result;
}

- (NSArray *)reject:(BKValidationBlock)block {
    NSArray *result = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return !block(obj);
    }]];
    
    if (!result.count)
        return nil;
    
    return result;
}

- (NSArray *)map:(BKTransformBlock)block {
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
    __block id result = nil;
    BK_SET_RETAINED(result, initial);
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BK_SET_RETAINED(result, block(result, obj));
    }];
    
    return BK_AUTORELEASE(result);
}

@end
