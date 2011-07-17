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
    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (!indexes.count)
        return nil;
    
    return [self objectAtIndex:[indexes firstIndex]];
}

- (NSArray *)select:(BKValidationBlock)block {
    NSArray *list = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return (block(obj));
    }]];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSArray *)reject:(BKValidationBlock)block {
    NSArray *list = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return (!block(obj));
    }]];
    
    if (!list.count)
        return nil;
    
    return list;
}

- (NSArray *)map:(BKTransformBlock)block {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if (!value)
            value = [NSNull null];
        
        [result addObject:value];
    }];
    
    return BK_AUTORELEASE(result);
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
