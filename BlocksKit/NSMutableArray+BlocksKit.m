//
//  NSMutableArray+BlocksKit.m
//  BlocksKit
//

#import "NSMutableArray+BlocksKit.h"

@implementation NSMutableArray (BlocksKit)

- (void)performSelect:(BKValidationBlock)block {
    NSIndexSet *list = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return !block(obj);
    }];
    
    if (!list.count)
        return;
    
    [self removeObjectsAtIndexes:list];
}

- (void)performReject:(BKValidationBlock)block {
    NSIndexSet *list = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (!list.count)
        return;
    
    [self removeObjectsAtIndexes:list];
}

- (void)performMap:(BKTransformBlock)block {
    NSMutableArray *new = BK_AUTORELEASE([self mutableCopy]);
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        
        if (!value)
            value = [NSNull null];
        
        if ([value isEqual:obj])
            return;
        
        [new replaceObjectAtIndex:idx withObject:value];
    }];
    
    [self setArray:new];
}

@end
