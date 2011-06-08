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
    
    if (indexes.count)
        return [self objectAtIndex:[indexes firstIndex]];
    
    return nil;
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
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id obj in self) {
        [list addObject:block(obj)];
    }
    NSArray *result = [list copy];
    [list release];
    return [result autorelease];
}

- (id)reduce:(id)initial withBlock:(BKAccumulationBlock)block {
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}

@end
